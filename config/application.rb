require_relative 'boot'

require 'rails'

require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module ArkHandler
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2
    config.api_only = true
    config.middleware.use Rack::Sendfile
    config.allow_concurrency = true
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
  end
end
