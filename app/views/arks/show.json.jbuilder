# frozen_string_literal: true

json.cache! [@ark], expires_in: 5.days do
  json.ark do
    json.partial! '/arks/ark', ark: @ark
  end
end
