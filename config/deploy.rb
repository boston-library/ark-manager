# config valid for current version and patch releases of Capistrano
lock "~> 3.17.1"
require File.expand_path('./environment', __dir__)

set :application, "ark-manager"
set :repo_url, "https://github.com/boston-library/#{fetch(:application)}.git"
set :user, Rails.application.credentials.dig(:deploy_testing, :user)

## Make user home path dynamic.
set :deploy_to, "/home/deployer/#{fetch(:application)}"

set :rvm_installed, "/home/#{fetch(:user)}/.rvm/bin/rvm"
set :rvm_ruby_version, File.read(File.expand_path('./../.ruby-version', __dir__)).strip
set :rvm_bundle_version, File.read(File.expand_path('./Gemfile.lock'))[-10..-1].strip

# Default value for :pty is false
set :pty, true

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "tmp/webpacker", "public/system", "vendor", "storage"
append :linked_files, 'config/database.yml', 'config/credentials/staging.key', 'config/environments/staging.rb'
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'bundle'

# Default value for keep_releases is 5
set :keep_releases, 5

# Costomized tasks that restart our services
namespace :boston_library do
  desc 'Gem update'
  task :gem_update do
    on roles(:app) do
      execute("#{fetch(:rvm_installed)} #{fetch(:rvm_ruby_version)} do gem update --system --no-document")
    end
  end

  desc 'Install new ruby if ruby-version is required'
  task :rvm_install_ruby do
    on roles(:app) do
      execute("#{fetch(:rvm_installed)} install #{fetch(:rvm_ruby_version)} -C --with-jemalloc")
      execute("#{fetch(:rvm_installed)} use #{fetch(:rvm_ruby_version)}")
    end
  end

  # desc 'Install bundler 2.3.26'
  desc "Install bundler #{fetch(:rvm_bundle_version)}"
  task :install_bundler do
    on roles(:app) do
      execute("#{fetch(:rvm_installed)} #{fetch(:rvm_ruby_version)} do gem install bundler:#{fetch(:rvm_bundle_version)}")
    end
  end

  desc 'ark-manager restarts ark_manager_puma service'
  task :restart_ark_manager_puma do
    on roles(:app), in: :sequence, wait: 5 do
      execute 'sudo /bin/systemctl restart ark_manager_puma.socket ark_manager_puma.service'
      sleep(5)
    end
  end

  desc 'Capistrano restarts nginx services'
  task :restart_nginx do
    on roles(:app), in: :sequence, wait: 5 do
      execute 'sudo /bin/systemctl reload nginx.service'
    end
  end
end

before :'rvm:check', :'boston_library:rvm_install_ruby'
after :'boston_library:gem_update', :'boston_library:install_bundler'
before :'bundler:install', :'boston_library:gem_update'
# after :'deploy:cleanup', :'boston_library:restart_ark_manager_puma'
# after :'boston_library:restart_ark_manager_puma', :'boston_library:restart_nginx'