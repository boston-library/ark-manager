class ApplicationController < ActionController::API

 rescue_from ActiveRecord::RecordNotFound, ImageNotFound, with: :not_found

  def not_found
    render json: { error: "Not Found" }, status: :not_found
  end

  def unprocessable(errors=[])
    render json: {errors: errors}, status: :unprocessable_entity
  end
end
