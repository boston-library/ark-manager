# frozen_string_literal: true

class ArkMinter < Noid::Rails::Minter::Db
  attr_reader :namespace

  def initialize(template = default_template, namespace = default_namespace)
    @namespace = namespace
    super(template)
  end

  def default_namespace
    Noid::Rails.config.namespace
  end

  protected

  def next_id
    # Only want one db connection at a time
    MinterState.connection_pool.with_connection do
      locked_inst = instance
      locked_inst.with_lock do
        minter = Noid::Minter.new(deserialize(locked_inst))
        id = minter.mint
        serialize(locked_inst, minter)
        break id
      end
    end
  end

  def deserialize(inst)
    filtered_hash = inst.as_json.slice('template', 'counters', 'seq', 'rand', 'namespace')
    filtered_hash['counters'] = filtered_hash['counters'].symbolize_keys if filtered_hash['counters']
    filtered_hash.symbolize_keys!
  end

  def serialize(inst, minter)
    inst.update_attributes!(
      seq: minter.seq,
      counters: minter.counters,
      rand: minter.instance_variable_get(:@rand)
     )
  end

  def instance
    MinterState.find_by!(
      namespace: namespace,
      template: template
    )
  rescue ActiveRecord::RecordNotFound
    MinterState.seed!(
      namespace: namespace,
      template: template
    )
  end
end
