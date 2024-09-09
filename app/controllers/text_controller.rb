# frozen_string_literal: true

class TextController < ApplicationController
  include ActionController::DataStreaming

  class TextNotFound < StandardError; end


  before_action :find_ark, only: :show
  def show
  end

  protected

  def send_plain_text_data()
  end

  def find_ark
    @ark = Ark.active.find_by!(noid: params[:noid])
  end
end
