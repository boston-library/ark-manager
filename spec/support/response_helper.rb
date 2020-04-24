# frozen_string_literal: true

module ResponseHelper
  def json_response
    Oj.load(response.body)
  rescue StandardError
    {}
  end
end

RSpec.configure do |config|
  %i(controller request).each do |type|
    config.include ResponseHelper, type: type
  end
end
