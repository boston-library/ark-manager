# frozen_string_literal: true

class ArksController < ApplicationController
  before_action :find_ark, only: [:show, :destroy]
  before_action :check_for_existing_ark, only: [:create]

  def show
    respond_to do |format|
      format.html { redirect_to @ark.redirect_url }
      format.json
    end
  end

  def create
    status = :created
    if @ark.present?
      Rails.logger.info 'Found a matching ark!'
      Rails.logger.debug @ark.to_s
      if @ark.deleted?
        Rails.logger.info 'Ark was deleted...Restoring...'
        status = :accepted
        @ark.deleted = false
      else
        render action: :show and return
      end
    else
      @ark = Ark.new(ark_params)
      Rails.logger.info 'Initialized new Ark!'
      Rails.logger.debug @ark.to_s
    end
    if @ark.save
       render status: status
    else
      Rails.logger.error 'Ark failed to create!'
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
      render json: { errors: @ark.errors }, status: :unprocessable_entity
    end
  end


  private
  def find_ark
    if params[:object_in_view]
      @ark = Ark.object_in_view(params[:namespace], params[:noid]).first!
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
    if ark_errors.any?
      ark_errors.reduce([]) do |r, (att, msg)|
        r << {
                title: 'Unprocessable Entity',
                status: 422,
                detail: msg,
                source: {
                          pointer: "/data/attributes/#{att}"
                        }
                      }
      end
    else
      []
    end
  end
end
