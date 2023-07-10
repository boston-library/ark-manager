# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '~> 3.0.6'

gem 'bootsnap', '>= 1.1.0', require: false
# Reduces boot times through caching; required in config/boot.rb
gem 'connection_pool', '~> 2.4'
gem 'down', '~> 5.4'
gem 'faraday', '~> 1.10', '< 2'
gem 'friendly_id', '~> 5.4'
gem 'jbuilder', '~> 2.11'
gem 'net-http-persistent', '>= 3.1'
gem 'noid-rails', '~> 3.0'
gem 'oj', '~> 3.15'
gem 'pg', '>= 0.18', '< 2.0'
# Use postgresql as the database for Active Record
gem 'puma', '~> 5.6.5'
# Use Puma as the app server
gem 'rack-cors', '~> 1.1'
# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rails', '~> 6.1.7', '< 7'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'redis', '~> 4.8'
gem 'rsolr', '~> 2.5'
gem 'rswag-api', '~> 2.6'

gem 'sd_notify', group: [:production, :staging]

group :development, :test do
  gem 'awesome_print', '~> 1.9'
  gem 'capistrano', '~> 3.17', require: false
  gem 'capistrano3-puma', ' ~> 5.1'
  gem 'capistrano-rails', '~> 1.4', require: false
  gem 'capistrano-rvm'
  gem 'dotenv-rails', '~> 2.8'
  gem 'factory_bot_rails', '~> 6.2'
  gem 'faker', '~> 2.23'
  gem 'pry', '~> 0.13.1'
  gem 'pry-rails'
  gem 'rspec-rails', '~> 5.1'
  gem 'rswag-specs', '~> 2.6'
  gem 'rubocop', '~> 1.36', require: false
  gem 'rubocop-performance', '~> 1.15', require: false
  gem 'rubocop-rails', '~> 2.16', require: false
  gem 'rubocop-rspec', require: false
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
end

group :test do
  gem 'coveralls', require: false
  gem 'database_cleaner-active_record', '~> 2'
  gem 'rails-controller-testing', '~> 1.0'
  gem 'shoulda-matchers', '~> 5.2'
  gem 'vcr', '~> 6.1'
  gem 'webmock', '~> 3.18'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
