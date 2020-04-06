# frozen_string_literal: true

class ArksController < ApplicationController
  beofre_action :find_ark, only: [:show, :destroy]

  def show
    render json: @ark
  end

  def create
    Rails.logger.debug "=== Params of :ark are: #{params[:ark].inspect} ==="

    if ark_params[:parent_pid]
      Rails.logger.debug "===Found parent pid-#{params[:parent_id]}==="

      @ark = Ark.by_parent_pid(ark_params[:parent_pid]).by_local_identifier(ark_params[:local_original_identifier], ark_params[:local_original_identifier_type]).first
    else
      @ark = Ark.by_local_identifier(ark_params[:local_original_identifier], ark_params[:local_original_identifier_type]).first
    end

    if @ark.present?

      Rails.logger.debug "Found a matching ark! : \n"
      Rails.logger.debug @ark.to_s

      if @ark.deleted?

        Rails.logger.debug "Found a matching ark! : \n"
        Rails.logger.debug @ark.to_s

        @ark.deleted = false
      end
    else
      @ark = Ark.new(ark_params)
      Rails.logger.debug "Made a new ark! : \n"
      Rails.logger.debug @ark.to_s
    end

    if @ark.save
      render json: @ark, status: :created
    else
      Rails.logger.error "Errors! : " + @ark.errors.full_messages.join("\n")
      render json: { errors: @ark.errors }, status: :unprocessable_entity
    end
  end

  def object_in_view
    @ark = Ark.active.by_namespace_ark(params[:namespace]).find_by!(noid: params[:noid])
    redirect_to @ark.redirect_base_url
  end

  def destroy
    @ark.deleted = true
    if @ark.save
      head: :no_content
    else
      render json: { errors: @ark.errors }, status: :unprocessable_entity
    end
  end

  private
  def find_ark
    @ark = Ark.active.find(params[:id])
  end

  def check_for_existing_ark
  end

  def ark_params
    params.require(:ark).permit(:local_original_identifier, :local_original_identifier_type, :namespace_ark, :namespace_id, :url_base, :model_type, :parent_pid, secondary_parent_pids: [])
  end
end
