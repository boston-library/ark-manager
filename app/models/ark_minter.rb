# frozen_string_literal: true

class ArkMinter < Noid::Rails::Minter::Db
  attr_reader :namespace
  MINTER_MUTEX = Mutex.new

  def initialize(template = default_template, namespace = default_namespace)
    @namespace = namespace || default_namespace
    super(template)
  end

  def default_namespace
    Noid::Rails.config.namespace
  end

  def mint
    Thread.new do
      Thread.current.report_on_exception = false
      ActiveRecord::Base.connection_pool.with_connection do
        MINTER_MUTEX.synchronize do
          loop do
            pid = next_id
            break pid unless identifier_in_use?(pid)
          end
        end
      end
    end.value
  end

  def current_arks
    @current_arks ||= Ark.select(:noid)
  end

  protected

  def next_id
    id = nil
    locked_inst = instance
    locked_inst.with_lock do
      minter = Noid::Minter.new(deserialize(locked_inst))
      minter.seed(Process.pid)
      id = minter.mint
      serialize(locked_inst, minter)
    end
    id
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
    # NOTE In production we want to control the Creation/Existence of MinterState objects in the seeds task. Creating them on the fly is ok in dev/test. So if the MinterState doesn't exist in production it will re raise the exception.
    # rubocop:disable Rails/UnknownEnv
    raise e if Rails.env.production? || Rails.env.staging?

    MinterState.seed!(
      namespace: namespace,
      template: template.to_s
    )
    # rubocop:enable Rails/UnknownEnv
  end

  private

  def identifier_in_use?(id)
    Noid::Rails.config.identifier_in_use.call(id, current_arks)
  end
end
