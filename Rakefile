# frozen_string_literal: true

require_relative 'config/application'

Rails.application.load_tasks

if %w(development test).member?(ENV.fetch('RAILS_ENV', 'development'))
  task default: :ci
  Rake::Task.define_task(:environment)

  require 'coveralls/rake/task'
  Coveralls::RakeTask.new

  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:rubocop) do |task|
    task.fail_on_error = true
  end

  desc 'Run rubocop, specs, and push to coveralls'
  task ci: [:rubocop, :spec]
end
