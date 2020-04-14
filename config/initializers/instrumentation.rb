# frozen_string_literal: true

ActiveSupport::Notifications.subscribe 'arks.mint' do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)

  Rails.logger.info 'Ark Minted Metrics...'
  Rails.logger.info event.to_s
end
