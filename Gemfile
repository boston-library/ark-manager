# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '~> 2.7'

gem 'bootsnap', '>= 1.1.0', require: false
# Reduces boot times through caching; required in config/boot.rb
gem 'connection_pool', '~> 2.2'
gem 'down', '~> 5.2'
gem 'faraday', '~> 1.5'
gem 'friendly_id', '~> 5.4'
gem 'jbuilder', '~> 2.11'
gem 'net-http-persistent', '>= 3.1'
gem 'noid-rails', '~> 3.0'
gem 'oj', '~> 3.12'
gem 'pg', '>= 0.18', '< 2.0'
# Use postgresql as the database for Active Record
gem 'puma', '~> 5.4'
# Use Puma as the app server
gem 'rack-cors', '~> 1.1'
# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rails', '~> 6.0.4', '< 6.1'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'redis', '~> 4.3'
gem 'rsolr', '~> 2.3'
gem 'rswag-api', '~> 2.4'

group :development, :test do
  gem 'awesome_print', '~> 1.9'
  gem 'dotenv-rails', '~> 2.7'
  gem 'factory_bot_rails', '~> 6.2'
  gem 'faker', '~> 2.18'
  gem 'pry', '~> 0.14'
  gem 'pry-rails', '~> 0.3'
  gem 'rspec-rails', '~> 4.0'
  gem 'rswag-specs', '~> 2.4'
  gem 'rubocop', '~> 0.75.1', require: false
  gem 'rubocop-performance', '~> 1.5', require: false
  gem 'rubocop-rails', '~> 2.4.2', require: false
  gem 'rubocop-rspec', require: false
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
end

group :test do
  gem 'coveralls', require: false
  gem 'database_cleaner-active_record', '~> 2'
  gem 'rails-controller-testing', '~> 1.0'
  gem 'shoulda-matchers', '~> 4.5'
  gem 'vcr', '~> 6'
  gem 'webmock', '~> 3.13'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
