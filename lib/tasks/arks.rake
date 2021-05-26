# frozen_string_literal: true

require_relative '../scripts'

namespace :arks do
  desc 'Import old Ark Manger DB from CSV'
  task :import, [:csv_path] => [:environment] do |_t, args|
    puts "Preparing to import csv of ark manager database at #{args[:csv_path]}"

    raise "No csv found at #{args[:csv_path]}!" if !File.file?(args[:csv_path])

    Scripts.run_import(args[:csv_path])

    puts 'Import task complete!'
  end
end
