# frozen_string_literal: true

module ArkErrorHelper
  def all_ark_errors
    ark = Ark.new
    ark.valid?
    errors = ark.errors.messages.reduce([]) do |r, (attr, msg)|
      r << {
        title: 'Unprocessable Entity',
              status: 422,
              detail: msg.join(','),
              source: { pointer: "/data/attributes/#{attr}" }
      }.as_json
    end
    { 'errors' => errors }
  end
end

RSpec.configure do |config|
  %i(controller request).each do |type|
    config.include ArkErrorHelper, type: type
  end
end
