# frozen_string_literal: true

NAMESPACES = [
  Noid::Rails.config.namespace,
  ENV.fetch('ARK_MANAGER_OAI_NAMESPACE') { 'oai-dev' }
].freeze

TEMPLATE = Noid::Rails.config.template.to_s

MinterState.connection_pool.with_connection do
  puts "Seeding default MinterStates with namespaces #{NAMESPACES.inspect} and template: #{TEMPLATE}"
  NAMESPACES.each do |namespace|
    puts "Checking if namespace: #{namespace} exists...."
    next if MinterState.exists?(template: TEMPLATE, namespace: namespace)

    puts "No minter state with namespace: #{namespace} found! Seeding..."

    begin
      MinterState.seed!(template: TEMPLATE, namespace: namespace)
    rescue StandardError => e
      puts "Failed to seed MinterState with template: #{TEMPLATE} and namespace: #{namespace}"
      puts "Reason Given #{e.message}"
    end
    puts 'Seed success!'
  end
  puts 'Default MinterStates seed task complete'
end
