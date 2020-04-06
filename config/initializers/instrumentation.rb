ActiveSupport::Notifications.subscribe "arks.mint" do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)

  Rails.logger.info 'Ark Minted Metrics...'
  Rails.logger.info "#{event}"
end
