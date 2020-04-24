# frozen_string_literal: true

class MinterService < ApplicationService
  attr_reader :minter

  def initialize(namespace = Noid::Rails.config.namespace)
    @minter = Noid::Rails.config.minter_class.new(Noid::Rails.config.template, namespace)
  end

  def call
    begin
      return @minter.mint
    rescue StandardError => e
      errors.add(:base, e.message)
    end
    nil
  end
end
