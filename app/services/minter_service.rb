# frozen_string_literal: true

class MinterService < ApplicationService
  attr_reader :minter_service

  def initialize(namespace = Noid::Rails.config.namespace)
    @minter_service = Noid::Rails.config.minter_class.new(Noid::Rails.config.template, namespace)
  end

  def call
    @minter_service.mint
  end
end
