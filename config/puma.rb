# frozen_string_literal: true

# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
#

rails_env = ENV.fetch('RAILS_ENV') { 'development' }
max_threads_count = ENV.fetch('RAILS_MAX_THREADS') { 5 }
min_threads_count = ENV.fetch('RAILS_MIN_THREADS') { max_threads_count }
app_dir = File.expand_path('..', __dir__)

threads min_threads_count, max_threads_count
workers ENV.fetch('WEB_CONCURRENCY') { 2 }

worker_timeout 3600 if rails_env == 'development'

environment rails_env

# New feature that reduces latency https://github.com/puma/puma/blob/master/5.0-Upgrade.md#lower-latency-better-throughput
wait_for_less_busy_worker

preload_app!

# Best Practice is to reconnect any Non Active Record Connections on boot in clustered mode
on_worker_boot do
  ActiveRecord::Base.establish_connection
end

if %w(staging production).member?(rails_env)
  bind "unix://#{app_dir}/tmp/sockets/ark_manager_puma.sock"
  stdout_redirect("#{app_dir}/log/puma.stdout.log", "#{app_dir}/log/puma.stderr.log", true)
  pidfile "#{app_dir}/tmp/pids/ark_manager_server.pid"
  state_path "#{app_dir}/tmp/pids/ark_manager_server.state"
else
  port ENV.fetch('PORT') { 3000 }
  stdout_redirect('/dev/stdout', '/dev/stderr')
  pidfile "#{app_dir}/tmp/pids/server.pid"
  state_path "#{app_dir}/tmp/pids/server.state"
  plugin :tmp_restart
end
