# frozen_string_literal: true

module ServiceClass
   attr_reader :result

  module ClassMethods
    def call(*args)
      new(*args).call
    end
  end

  def self.prepended(base)
    base.extend ClassMethods
  end

  def call
    fail NotImplementedError unless defined?(super)

    @called = true
    @result = super

    self
  end

  def success?
    called? && !failure?
  end
  alias_method :successful?, :success?

  def failure?
    called? && errors.any?
  end

  def errors
    return super if defined?(super)

    raise NotImplementedError, 'include ActiveModel::Validations missing in class!'
  end

  private
  def called?
    return @called if defined?(@called)

    @called = false
  end

end
