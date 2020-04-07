# frozen_string_literal: true

module ArkHandler
  extend ActiveSupport::Concern

  private

  def active_ark_scope
    return @active_ark_scope if defined?(@active_ark_scope)

    @active_ark_scope = Ark.active
  end

  
end
