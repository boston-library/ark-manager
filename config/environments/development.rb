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

  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  elsif ENV.fetch('ARK_MANAGER_REDIS_CACHE_URL', '').present?
    config.action_controller.perform_caching = true
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{1.day.to_i}"
    }
    config.cache_store = :redis_cache_store, {
      url: ENV['ARK_MANAGER_REDIS_CACHE_URL'],
      pool_size: ENV.fetch('RAILS_MAX_THREADS') { 5 },
      pool_timeout: 10,
      expires_in: 24.hours
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true
  config.debug_exception_response_format = :api
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
