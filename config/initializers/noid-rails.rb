# frozen_string_literal: true

require 'noid-rails'

Rails.configuration.to_prepare do
  MinterState.class_eval do
    serialize :counters, Oj
  end

  Noid::Rails.configure do |config|
    config.template = '.reeddeeddk'
    config.namespace = ENV.fetch('ARK_MANAGER_DEFAULT_NAMESPACE') { 'bpl-dev' }
    config.minter_class = ArkMinter
    config.identifier_in_use = ->(noid) { Ark.select(:id, :noid).exists?(noid: noid) }
  end
end
