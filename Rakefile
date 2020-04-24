# frozen_string_literal: true

require_relative 'config/application'

Rails.application.load_tasks

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.fail_on_error = true
end

# In Travis, Rake::Task['spec'] runs by default, just add Rubocop
# though this is not as helpful for local dev
task default: [:rubocop]
