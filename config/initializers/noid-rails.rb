require 'noid-rails'

Noid::Rails.configure do |config|
  config.template = '.reeddeeddk'.freeze
  config.namespace = 'bpl-dev'.freeze
  config.minter_class = ArkMinter
  config.identifier_in_use = ->(noid){
    Ark.select(:id, :noid).exists?(noid: noid)
  }
end

MinterState.class_eval do
  serialize :counters, Oj
end
