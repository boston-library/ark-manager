# frozen_string_literal: true

require_relative 'boot'

require 'rails'

require 'active_model/railtie'
# require "active_job/railtie"
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_view/railtie'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ArkHandler
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0
    config.api_only = true
    config.middleware.use Rack::Sendfile

    config.action_dispatch.default_headers['X-Frame-Options'] = 'DENY'

    if Rails.env.development?
      console do
        require 'pry' unless defined? Pry
        require 'awesome_print'
        AwesomePrint.pry!
        config.console = Pry
      end
    end

    config.generators do |g|
      g.orm :active_record
      g.api_only = true
      g.test_framework :rspec, fixture: true
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
