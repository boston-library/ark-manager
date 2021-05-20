# frozen_string_literal: true

json.cache! [@ark], expires_in: 24.hours do
  json.ark do
    json.partial! '/arks/ark', ark: @ark
  end
end
