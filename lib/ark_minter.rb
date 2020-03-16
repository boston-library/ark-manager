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

  def mint
    ActiveRecord::Base.connection_pool.with_connection do
      super
    end
  end

  protected

  def instance
    MinterState.lock.find_by!(
      namespace: namespace,
      template: Noid::Rails.config.template
    )

  end
end
