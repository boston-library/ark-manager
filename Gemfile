source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.5.7'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.2.4.1'
# Use postgresql as the database for Active Record
gem "hiredis", "~> 0.6.0"
gem 'redis', '~> 4.0'
gem 'pg', '>= 0.18', '< 2.0'
# Use Puma as the app server
gem 'puma', '~> 3.12.1'
gem 'noid-rails', '~> 3.0.1'
# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.1.0', require: false
gem 'oj', '~> 3.9.2'
# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors', '~> 1.0.3'
gem 'friendly_id', '~> 5.3.0'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'awesome_print'
  gem 'pry'
  gem 'pry-byebug'
  gem 'dotenv-rails'
  gem 'rspec-rails', '~> 3.8.0'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
