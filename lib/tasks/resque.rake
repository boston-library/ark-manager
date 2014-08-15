require 'resque/pool/tasks'

# This provides access to the Rails env within all Resque workers
task 'resque:setup' => :environment

# Set up resque-pool
task 'resque:pool:setup' do
  ActiveRecord::Base.connection.disconnect!
  Resque::Pool.after_prefork do |job|
    ActiveRecord::Base.establish_connection
    Resque.redis.client.reconnect
  end
end

task :resque_stop do
  pid_file = 'tmp/pids/resque-pool.pid'
  pid = File.read(pid_file).to_i
  Process.kill 9, pid
  File.delete pid_file
end