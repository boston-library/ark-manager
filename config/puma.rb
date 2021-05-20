# frozen_string_literal: true

# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
#
workers ENV.fetch('WEB_CONCURRENCY') { 2 }

threads_count = ENV.fetch('RAILS_MAX_THREADS') { 5 }
threads threads_count, threads_count

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
#
bind 'tcp://0.0.0.0'
port        ENV.fetch('PORT') { 3000 } if ENV.fetch('RAILS_ENV', 'development') == 'development'
# Specifies the `environment` that Puma will run in.
#
environment ENV.fetch('RAILS_ENV') { 'development' }

stdout_redirect('/dev/stdout', '/dev/stderr', true)

app_dir = File.expand_path('..', __dir__)

pidfile "#{app_dir}/tmp/pids/server.pid"
state_path "#{app_dir}/tmp/pids/server.state"

worker_timeout 600

preload_app!

before_fork do
  Rails.logger.info 'Worker Forking...'
  ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
end

on_worker_boot do
  Rails.logger.info 'Booting Worker...'
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end
# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart
