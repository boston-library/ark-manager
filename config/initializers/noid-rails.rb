# frozen_string_literal: true

require 'noid-rails'

Rails.application.reloader.to_prepare do
  module MinterStateOverride
    extend ActiveSupport::Concern

    included do
      serialize :counters, Oj

      before_create { self.rand = Marshal.dump(Random.new(Process.pid)) if rand.blank? }
    end
  end

  MinterState.send(:include, MinterStateOverride)

  Noid::Rails.configure do |config|
    config.template = '.reeddeeddk'
    config.namespace = ENV.fetch('ARK_MANAGER_DEFAULT_NAMESPACE') { Rails.application.credentials.dig(:ark, :default_namespace) || raise('no value for default ark namespace found!') }
    config.minter_class = ArkMinter
    config.identifier_in_use = ->(noid) { Ark.identifier_in_use?(noid) }
  end
end
