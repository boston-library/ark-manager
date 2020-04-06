# frozen_string_literal: true

class ApplicationController < ActionController::API

  include ActionController::ImplicitRender
  include ActionView::Layouts

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def not_found
    render json: { error: "Not Found" }, status: :not_found
  end

  def unprocessable(errors=[])
    render json: {errors: errors}, status: :unprocessable_entity
  end
end
