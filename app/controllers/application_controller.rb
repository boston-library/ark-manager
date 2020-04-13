# frozen_string_literal: true

class ApplicationController < ActionController::API
  APP_INFO = {
    app_name: 'ark-manager',
    author: 'Ben Barber',
    organization: 'Boston Public Library',
    version: '2',
  }.freeze

  include ActionController::ImplicitRender
  include ActionView::Layouts
  include ActionController::Caching

  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActionController::RoutingError, with: :not_found
  rescue_from ActionController::UnpermittedParameters, with: :bad_request

  def app_info
    render json: Oj.dump(APP_INFO), status: :ok
  end

  def route_not_found
    raise ActionController::RoutingError, 'No Route Matches This Url'
  end

  def not_found(e)
    status = :not_found
    response_hash = build_error_response('Not Found', e&.message, status, request.env['PATH_INFO'])
    render json: Oj.dump(response_hash), status: status
  end

  def bad_request(e)
    status = :bad_request
    response_hash = build_error_response('Bad Request', e&.message, status, request.env['PATH_INFO'])
    render json: Oj.dump(response_hash), status: status
  end

  def internal_server_error(e)
    status = :internal_server_error
    response_hash = build_error_response('Internal Server Error', e&.message, status, request.env['PATH_INFO'])
    render json: Oj.dump(response_hash), status: status
  end

  private
  def authenticate!
  end

  def build_error_response(title, message, status, pointer)
    {
      errors: [{
        title: title,
        status: Rack::Utils.status_code(status),
        message: message,
        detail: {
          pointer: pointer
        }
      }]
    }.as_json
  end
end
