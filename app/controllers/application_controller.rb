# frozen_string_literal: true

class ApplicationController < ActionController::API
  APP_INFO = {
    app_name: 'ark-manager',
    author: 'Ben Barber',
    organization: 'Boston Public Library',
    version: '2',
  }.freeze

  NOT_FOUND_ERROR_CLASSES = [
    'ActiveRecord::RecordNotFound',
    'ActionController::RoutingError',
    'PreviewController::ImageNotFound',
    'TextController::TextNotFound'
  ].freeze

  UNPROCESSABLE_CONTENT_CLASSES = [
    'ActiveRecord::RecordInvalid',
    'ActiveRecord::RecordNotSaved'
  ].freeze

  include ActionController::ImplicitRender
  include ActionView::Layouts
  include ActionController::Caching

  rescue_from StandardError, with: :handle_error

  def app_info
    render json: Oj.dump(APP_INFO), status: :ok
  end

  def route_not_found
    raise ActionController::RoutingError, 'No Route Matches This Url'
  end

  protected

  def handle_error(e)
    Rails.logger.error '============================================='
    Rails.logger.error e.class&.name
    Rails.logger.error e&.message
    Rails.logger.error e&.backtrace&.first(5)
    Rails.logger.error '============================================='

    status = case e&.class&.name
             when 'PreviewController::PreviewServiceError', 'TextController::TextPlainServiceError'
               e&.status || :internal_server_error
             when 'ActionController::UnknownFormat'
               :not_acceptable
             when *NOT_FOUND_ERROR_CLASSES
               :not_found
             when *UNPROCESSABLE_CONTENT_CLASSES
               :unprocessable_entity
             else
               :internal_server_error
             end

    head status and return if !request.format.json?

    response_body = build_error_response(status.to_s.humanize, e&.message, status, request.env['PATH_INFO'])
    render json: Oj.dump(response_body), status: status
  end

  # def authenticate!
  #   # TODO
  # end

  private

  def build_error_response(title, message, status, pointer)
    {
      errors: [{
        title: title,
        status: Rack::Utils.status_code(status),
        detail: message,
        source: {
          pointer: pointer
        }
      }]
    }.as_json
  end
end
