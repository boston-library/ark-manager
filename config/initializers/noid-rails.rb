# frozen_string_literal: true

require 'noid-rails'

Rails.application.reloader.to_prepare do
  module MinterStateSerializePatch
    extend ActiveSupport::Concern

    included do
      serialize :counters, Oj
    end
  end

  MinterState.send(:include, MinterStateSerializePatch)

  Noid::Rails.configure do |config|
    config.template = '.reeddeeddk'
    config.namespace = ENV.fetch('ARK_MANAGER_DEFAULT_NAMESPACE') { 'bpl-dev' }
    config.minter_class = ArkMinter
    config.identifier_in_use = ->(noid) { Ark.select(:id, :noid).exists?(noid: noid) }
  end
end
