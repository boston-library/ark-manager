# frozen_string_literal: true

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.

  if ENV['REDIS_DOCKER_URL'].present? || ENV['REDIS_CACHE_URL'].present?
    config.cache_store = :redis_cache_store,
                         {
                           driver: :hiredis,
                           url: ENV['REDIS_DOCKER_URL'].presence || ENV['REDIS_CACHE_URL'].presence,
                           expires_in: 90.minutes
                         }
  else
    config.cache_store = config.cache_store = :memory_store
  end

  config.action_controller.perform_caching = true

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  config.log_formatter = ::Logger::Formatter.new

  # Prepend all log lines with the following tags.

  if ENV['RAILS_LOG_TO_STDOUT'].present?
    config.log_tags = [:request_id]
    config.log_level = :debug
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end
end
