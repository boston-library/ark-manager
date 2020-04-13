# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.4.2'
# Use postgresql as the database for Active Record
gem "hiredis", "~> 0.6.0"
gem 'redis', '~> 4.1'
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 4.3'
gem 'noid-rails', '~> 3.0'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false
gem 'oj', '~> 3.10'
# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors', '~> 1.1'
gem 'friendly_id', '~> 5.3.0'
gem 'rswag-api', '~> 2.3'
gem 'rswag-ui', '~> 2.3'
gem 'jbuilder', '~> 2.10'

group :development, :test do
  gem 'awesome_print', '~> 1.8'
  gem 'dotenv-rails', '~> 2.7'
  gem 'factory_bot_rails', '~> 5.0'
  gem 'faker', '~> 2.6.0'
  gem 'pry', '~> 0.12'
  gem 'pry-byebug', '~> 3.8'
  gem 'pry-rails', '~> 0.3.9'
  gem 'rspec-rails', '~> 3.9', '< 4.0'
  gem 'rswag-specs', '~> 2.3'
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
  gem 'database_cleaner-active_record', '~> 1.8'
  gem 'shoulda-matchers', '~> 4.1'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
