# frozen_string_literal: true

class TextPlainContentService < ApplicationService
  TXT_DEST_FOLDER = Rails.application.config_for('image_previews')[:cache_folder]

  def initialize()
  end

  def call
  end
end