# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.8'

gem 'bootsnap', '>= 1.1.0', require: false
# Reduces boot times through caching; required in config/boot.rb
gem 'connection_pool', '~> 2.4'
gem 'down', '~> 5.4'
gem 'faraday', '~> 1.10', '< 2'
gem 'friendly_id', '~> 5.5'
gem 'jbuilder', '~> 2.11'
gem 'net-http-persistent', '>= 3.1'
gem 'noid-rails', '~> 3.2'
gem 'oj', '~> 3.16'
gem 'pg', '>= 0.18', '< 2.0'
# Use postgresql as the database for Active Record
gem 'puma', '~> 6.6'
# Use Puma as the app server
gem 'rack-cors', '~> 1.1'
# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rails', '~> 7.1.4'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'redis', '~> 5'
gem 'rsolr', '~> 2.5'
gem 'rswag-api', '~> 2.10'

group :development, :test do
  gem 'awesome_print', '~> 1.9'
  gem 'capistrano', '~> 3.17.3', require: false
  gem 'capistrano-rails', '~> 1.4', require: false
  gem 'capistrano-rvm'
  gem 'debug', platforms: %i(mri mingw x64_mingw)
  gem 'dotenv-rails', '~> 2.8'
  gem 'factory_bot_rails', '~> 6.2'
  gem 'faker', '~> 3.2'
  gem 'rspec-rails', '~> 6.0'
  gem 'rswag-specs', '~> 2.6'
  gem 'rubocop', '~> 1.66.1', require: false
  gem 'rubocop-factory_bot', '~> 2.24.0', require: false
  gem 'rubocop-performance', '~> 1.21.1', require: false
  gem 'rubocop-rails', '~> 2.26.1', require: false
  gem 'rubocop-rspec', '~> 2.31.0', require: false
end

group :development do
  gem 'listen', '~> 3.2'
end

group :test do
  gem 'coveralls_reborn', '~> 0.28.0', require: false
  gem 'database_cleaner-active_record', '~> 2.1'
  gem 'rails-controller-testing', '~> 1.0'
  gem 'shoulda-matchers', '~> 6.4'
  gem 'vcr', '~> 6.2'
  gem 'webmock', '~> 3.19'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
