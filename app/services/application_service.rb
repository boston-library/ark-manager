# frozen_string_literal: true

class ApplicationService
  def self.inherited(base)
    base.prepend ServiceClass
    base.include ActiveModel::Validations
  end
end
