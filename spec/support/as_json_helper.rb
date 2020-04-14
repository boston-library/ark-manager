# frozen_string_literal: true

module AsJsonHelper
  DATE_FIELDS = %w(created_at updated_at).freeze

  def ark_as_json(ark)
    ark_json = ark.as_json(root: true, except: [:deleted, :noid])
    ark_json['ark'].compact!
    DATE_FIELDS.each do |date_attr|
      ark_json['ark'][date_attr] = ark_json['ark'][date_attr].as_json if ark_json['ark'][date_attr]
    end
    ark_json
  end
end

RSpec.configure do |config|
  %i(controller request).each do |type|
    config.include AsJsonHelper, type: type
  end
end
