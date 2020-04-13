# frozen_string_literal: true

module ResponseHelper
  def json_response
    Oj.load(response.body)
  rescue StandardError
    {}
  end
end

RSpec.configure do |config|
  config.include ResponseHelper, type: :controller
  config.include ResponseHelper, type: :request
end
