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
    config.load_defaults 7.1

    config.api_only = true
    config.middleware.use Rack::Sendfile
    # As of rails 7 any redirect to an external site not based on the current domain/subdomain raises an
    # ActionController::Redirecting::UnsafeRedirectError by default so the following config setting needs to be set
    # to false to prevent this error from raising in the case of this app
    config.action_controller.raise_on_open_redirects = false
    config.action_dispatch.default_headers['X-Frame-Options'] = 'DENY'
    config.active_support.cache_format_version = 7.1
    config.autoload_lib(ignore: %w(tasks))

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
