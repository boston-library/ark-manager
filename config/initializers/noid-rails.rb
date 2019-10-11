require 'noid-rails'

Noid::Rails.configure do |config|
  config.template = '.reeddeeddk'.freeze
  config.minter_class = ArkMinter
end
