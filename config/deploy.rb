# frozen_string_literal: true

# config valid for current version and patch releases of Capistrano
lock '~> 3.17.1'

set :use_sudo, false

## STAGE_NAME is a paramter from Jenkins job: "staging", "qc", and "testing", or "production"
set :stage_case, ENV['STAGE_NAME']

set :application, 'ark-manager'
set :repo_url, "https://github.com/boston-library/#{fetch(:application)}.git"
set :user, ENV['DEPLOY_USER']

## Make user home path dynamic.
set :deploy_to, "/home/#{fetch(:user)}/railsApps/#{fetch(:application)}"

set :rvm_installed, "/home/#{fetch(:user)}/.rvm/bin/rvm"
set :rvm_ruby_version, File.read(File.expand_path('./../.ruby-version', __dir__)).strip
set :rvm_bundle_version, File.read(File.expand_path('./Gemfile.lock'))[-10..-1].strip

# Default value for :pty is false
set :pty, true

# Default value for linked_dirs is []
append :linked_files, 'config/database.yml', 'config/credentials/staging.key', 'config/environments/staging.rb', 'config/credentials/production.key'
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

  ## Update ruby version for systemd service
  desc 'Update ruby version for systemd service'
  task :update_service_ruby do
    on roles(:app) do
      execute("sudo rm /etc/systemd/system/\"#{fetch(:application)}\"_puma.service.d/override.conf | true
              SERVICE_RUBY_VERSION=`cat /home/\"#{fetch(:user)}\"/railsApps/\"#{fetch(:application)}\"/current/.ruby-version`
              echo \"SERVICE_RUBY_VERSION IS: \" ${SERVICE_RUBY_VERSION}
              echo '[Service]' > override.conf
              echo \"Environment=SERVICE_RUBY_VERSION=${SERVICE_RUBY_VERSION}\" >> override.conf
              sudo mv override.conf /etc/systemd/system/\"#{fetch(:application)}\"_puma.service.d/override.conf
              sudo /bin/systemctl daemon-reload")
    end
  end

  # rubocop:disable Layout/LineLength
  desc 'Run a console command to test -rails console-'
  task :rails_console_runner do
    on roles(:app), in: :sequence, wait: 5 do
      as fetch(:user) do
        within release_path do
          puts capture("cd #{release_path}; #{fetch(:rvm_installed)} #{fetch(:rvm_ruby_version)} do #{release_path}/bin/rails runner -e #{fetch(:stage_case)} \"puts 'rails console works'\"")
        end
      end
    end
  end
  # rubocop:enable Layout/LineLength

  desc "#{fetch(:application)} restarts #{fetch(:application)}_puma service"
  task :"restart_#{fetch(:application)}_puma" do
    on roles(:app), in: :sequence, wait: 5 do
      execute "sudo /bin/systemctl restart #{fetch(:application)}_puma.service"
      sleep(5)
    end
  end

  desc 'Capistrano restarts nginx services'
  task :restart_nginx do
    on roles(:app), in: :sequence, wait: 5 do
      execute 'sudo /bin/systemctl reload nginx.service'
    end
  end

  desc 'List current releases'
  task :list_releases do
    on roles(:app) do
      execute "ls -alt #{fetch(:deploy_to)}/releases"
    end
  end
end

after :'deploy:updating', :'boston_library:gem_update'
after :'boston_library:gem_update', :'boston_library:rvm_install_ruby'
after :'boston_library:rvm_install_ruby', :'boston_library:install_bundler'
after :'boston_library:install_bundler', :'bundler:config'
after :'bundler:config', :'bundler:install'
after :'deploy:cleanup', :'boston_library:rails_console_runner'
after :'boston_library:rails_console_runner', :'boston_library:update_service_ruby'
after :'boston_library:update_service_ruby', :"boston_library:restart_#{fetch(:application)}_puma"
after :"boston_library:restart_#{fetch(:application)}_puma", :'boston_library:restart_nginx'
after :'boston_library:restart_nginx', :'boston_library:list_releases'
