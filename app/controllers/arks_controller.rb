# frozen_string_literal: true

class ArksController < ApplicationController
  before_action :find_ark, only: [:show, :destroy]
  before_action :check_for_existing_ark, only: [:create]

  def show
    redirect_to @ark.redirect_url and return if redirect_for_object?
    # Renders JSON if !redirect_for_object
  end

  def create
    if @ark
      Rails.logger.info 'Found a matching ark!'
      Rails.logger.debug @ark.to_s
      render action: :show and return unless @ark.deleted?

      Rails.logger.info "Ark #{@ark.noid} was deleted...Restoring..."
      status = :accepted
      @ark.deleted = false
    else
      status = :created
      @ark = Ark.new(ark_params)
      Rails.logger.info 'Initialized new Ark!'
      Rails.logger.debug @ark.to_s
    end

    if @ark.save
       render status: status
    else
      Rails.logger.error 'Ark failed to save!'
      Rails.logger.error @ark.errors.full_messages.join("\n")
      @errors = build_ark_errors(@ark.errors)
      render status: :unprocessable_entity
    end
  end

  def destroy
    @ark.deleted = true
    if @ark.save
      head :no_content
    else
      errors = build_ark_errors(@ark.errors)
      render json: { errors: errors }, status: :unprocessable_entity
    end
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
    Rails.logger.info 'Checking for existing Ark...'
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
    return [{
      title: 'Unprocessable Entity',
      status: 422,
      detail: 'Unknown Errors caused Ark to fail saving! Check the logs!',
      source: { pointer: '/data/attributes/:unknown'}
    }] if ark_errors.blank?

    ark_errors.reduce([]) do |r, (attr, msg)|
      r << {
              title: 'Unprocessable Entity',
              status: 422,
              detail: msg,
              source: { pointer: "/data/attributes/#{attr}" }
           }
    end
  end
end
