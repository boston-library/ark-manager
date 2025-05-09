# frozen_string_literal: true

class ArkMinter < Noid::Rails::Minter::Db
  attr_reader :namespace

  def initialize(template = default_template, namespace = default_namespace)
    @namespace = namespace || default_namespace
    super(template)
  end

  def default_namespace
    Noid::Rails.config.namespace
  end

  def mint
    Thread.new do
      Rails.application.reloader.wrap do
        Thread.current.report_on_exception = false
        Thread.current[:pid] = nil
        Fiber.new do
          loop do
            pid = next_id
            Fiber.yield pid unless identifier_in_use?(pid)
          end
        end.resume
      end
    end.value
  end

  protected

  def next_id
    MinterState.connection_pool.with_connection do
      locked_inst = instance
      locked_inst.with_lock('FOR UPDATE NOWAIT', requires_new: true) do
        minter = Noid::Minter.new(deserialize(locked_inst))
        Thread.current[:pid] = minter.mint
        serialize(locked_inst, minter)
      end
      synchronize_states!(locked_inst)
    end
    Thread.current[:pid]
  end

  def deserialize(inst)
    filtered_hash = inst.as_json.slice('template', 'counters', 'seq', 'rand', 'namespace')
    filtered_hash['counters'] = filtered_hash['counters'].map(&:symbolize_keys) if filtered_hash['counters']
    filtered_hash.symbolize_keys!
  end

  def serialize(inst, minter)
    inst.update!(
      seq: minter.seq,
      counters: minter.counters,
      rand: Marshal.dump(minter.instance_variable_get(:@rand))
    )
  end

  def instance
    MinterState.find_by!(
      namespace: namespace,
      template: template.to_s
    )
  rescue ActiveRecord::RecordNotFound => e
    # NOTE: In production we want to control the Creation/Existence of MinterState objects in the seeds task. Creating them on the fly is ok in dev/test. So if the MinterState doesn't exist in production it will re raise the exception.
    # rubocop:disable Rails/UnknownEnv
    raise e if Rails.env.production? || Rails.env.staging?

    MinterState.seed!(
      namespace: namespace,
      template: template.to_s
    )
    # rubocop:enable Rails/UnknownEnv
  end

  private

  def synchronize_states!(current_inst)
    MinterState.where.not(namespace: current_inst.namespace).find_each do |other_inst|
      other_inst.with_lock('FOR UPDATE NOWAIT', requires_new: true) do
        other_inst.update!(rand: current_inst.rand, seq: current_inst.seq, counters: current_inst.counters)
      end
    end
  end

  def identifier_in_use?(id)
    Noid::Rails.config.identifier_in_use.call(id)
  end
end
