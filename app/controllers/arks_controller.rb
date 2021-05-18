# frozen_string_literal: true

class ArksController < ApplicationController
  before_action :find_ark, except: [:create]
  before_action :check_for_existing_ark, only: [:create]

  def show
    redirect_to @ark.redirect_url and return if redirect_for_object?
    # Renders JSON if !redirect_for_object
    fresh_when last_modified: @ark.updated_at.utc, strong_etag: @ark
  end

  def create
    if @ark
      Rails.logger.debug 'Found a matching ark!'
      Rails.logger.debug @ark.to_s

      render action: :show, status: :ok and return if !@ark.deleted? && stale?(strong_etag: @ark, last_modified: @ark.updated_at.utc)

      Rails.logger.debug "Ark #{@ark.noid} was deleted...Restoring..."

      status = :accepted
      @ark.deleted = false
    else
      status = :created
      @ark = Ark.new(ark_params)

      Rails.logger.debug 'Initialized new Ark!'
      Rails.logger.debug @ark.to_s
    end

    render status: status and return if @ark.save

    Rails.logger.error 'Ark failed to save!'
    Rails.logger.error @ark.errors.full_messages.join("\n")

    @errors = build_ark_errors(@ark.errors)
    render status: :unprocessable_entity
  end

  def destroy
    @ark.deleted = true
    head :no_content and return if @ark.save

    errors = build_ark_errors(@ark.errors)
    render json: { errors: errors }, status: :unprocessable_entity
  end

  def iiif_manifest
    redirect_to "#{@ark.redirect_url}/manifest"
  end

  def iiif_canvas
    @canvas_object = Ark.select(:created_at, :namespace_ark, :noid, :pid, :url_base, :deleted).object_in_view(params[:namespace], params[:canvas_object_id]).first!

    redirect_to "#{@ark.redirect_url}/canvas/#{@canvas_object.pid}"
  end

  def iiif_annotation
    @annotation_object =  Ark.select(:created_at, :namespace_ark, :noid, :pid, :url_base, :deleted).object_in_view(params[:namespace], params[:annotation_object_id]).first!

    redirect_to "#{@ark.redirect_url}/annotation/#{@annotation_object.pid}"
  end

  def iiif_collection
    redirect_to "#{@ark.redirect_url}/iiif_collection"
  end

  def iiif_search
    iiif_query_params = iiif_search_params.to_query

    search_redirect_url = if iiif_query_params.blank?
                      "#{@ark.redirect_url}/iiif_search"
                    else
                      "#{@ark.redirect_url}/iiif_search?#{iiif_query_params}"
                    end
    redirect_to search_redirect_url
  end

  private

  def find_ark
    if params[:object_in_view]
      @ark = Ark.select(:created_at, :namespace_ark, :noid, :pid, :url_base, :deleted).object_in_view(params[:namespace], params[:noid]).first!
    else
      @ark = Ark.active.find(params[:id])
    end
  end

  def check_for_existing_ark
    Rails.logger.debug 'Checking for existing Ark...'
    Rails.logger.debug "==== :ark_params are #{ark_params.inspect} ===="

    if ark_params[:parent_id]
      @ark = Ark.with_parent_and_local_id(ark_params[:parent_pid], ark_params[:local_original_identifier], ark_params[:local_original_identifier_type]).first
    else
      @ark = Ark.with_local_id(ark_params[:local_original_identifier], ark_params[:local_original_identifier_type]).first
    end
  end

  def redirect_for_object?
    params[:object_in_view] || !request.format.json?
  end

  def iiif_search_params
    params.permit(:q, :motivation, :date, :user)
  end

  def ark_params
    params.require(:ark).permit(:local_original_identifier,
                                :local_original_identifier_type,
                                :namespace_ark,
                                :namespace_id,
                                :url_base,
                                :model_type,
                                :parent_pid,
                                secondary_parent_pids: [])
  end

  def build_ark_errors(ark_errors = {})
    return default_ark_error if ark_errors.blank?

    ark_errors.reduce([]) do |r, (attr, msg)|
      r << {
        title: 'Unprocessable Entity',
              status: 422,
              detail: msg,
              source: { pointer: "/data/attributes/#{attr}" }
      }
    end
  end

  def default_ark_error
    [{
      title: 'Unprocessable Entity',
      status: 422,
      detail: 'Unknown Errors caused Ark to fail saving! Check the logs!',
      source: { pointer: '/data/attributes/:unknown' }
    }]
  end
end
