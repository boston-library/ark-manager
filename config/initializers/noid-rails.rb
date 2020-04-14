# frozen_string_literal: true

require 'noid-rails'

Noid::Rails.configure do |config|
  config.template = '.reeddeeddk'
  config.namespace = 'bpl-dev'
  config.minter_class = ArkMinter
  config.identifier_in_use = ->(noid) { Ark.select(:id, :noid).exists?(noid: noid) }
end

MinterState.class_eval do
  serialize :counters, Oj
end
