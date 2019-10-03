class ArksController < ApplicationController
  beofre_action :find_ark, only: [:show, :destroy, :update]
  def show
    render json: @ark
  end

  def create
    Rails.logger.debug "Params of :ark are: #{params[:ark].inspect}"
    if params[:ark][:parent_pid]
      Rails.logger.debug "Found parent pid"
      @ark = Ark.unscoped.where(:local_original_identifier=>params[:ark][:local_original_identifier], :local_original_identifier_type=>params[:ark][:local_original_identifier_type], :parent_pid=>params[:ark][:parent_pid]).first
    else
      @ark = Ark.unscoped.where(:local_original_identifier=>params[:ark][:local_original_identifier], :local_original_identifier_type=>params[:ark][:local_original_identifier_type]).first
    end

    if @ark.present?
      Rails.logger.debug "Found a matching ark! : " + @ark.to_s
      if @ark.deleted
        @ark.deleted = false
      end
    else
      # ark_parameters = ActionController::Parameters.new(ark: {})
      # ark_parameters[:ark][:local_original_identifier] = params[:ark][:local_original_identifier]
      # ark_parameters[:ark][:local_original_identifier_type] = params[:ark][:local_original_identifier_type]
      # ark_parameters[:ark][:namespace_ark] = params[:ark][:namespace_ark]
      # ark_parameters[:ark][:namespace_id] = params[:ark][:namespace_id]
      # ark_parameters[:ark][:url_base] = params[:ark][:url_base]
      # ark_parameters[:ark][:model_type] = params[:ark][:model_type]
      # ark_parameters[:ark][:pid] = pid
      # ark_parameters[:ark][:noid] = IdService.getid(pid)
      # ark_parameters[:ark][:view_object] = "/search/"
      # ark_parameters[:ark][:view_thumbnail] = "/preview/"
      # ark_parameters[:ark][:parent_pid] = params[:ark][:parent_pid]

      @ark = Ark.new(ark_params)
      #Seperate as didn't work if assigned above...
      # @ark.secondary_parent_pids = params[:ark][:secondary_parent_pids].values if params[:ark][:secondary_parent_pids].present?

      Rails.logger.debug "Made a new ark! : " + @ark.to_s
    end

    if @ark.save
      render json: @ark, status: :created
    else
      Rails.logger.error "Errors! : " + @ark.errors
      render json: {errors: @ark.errors}, status: :unprocessable_entity
    end
  end

  def delete_ark
    @ark = Ark.where(:noid=>params[:ark][:pid])
    @ark.deleted = true
    @ark.save
  end

  def object_in_view
    @ark = Ark.where(:noid=>params[:noid])
    redirect_to redirect_base
    #puts "in object in view with pid: "  + params[:pid]
  end

  def iiif_manifest
    @ark = Ark.where(:noid=>params[:noid])
    redirect_to "#{redirect_base}/manifest"
  end

  def iiif_canvas
    @ark = Ark.where(:noid=>params[:noid])
    @canvas_object = Ark.where(:noid=>params[:canvas_object_id])
    redirect_to redirect_base + "/canvas/" + @canvas_object[0].namespace_id + ":" + @canvas_object[0].noid
  end

  def iiif_annotation
    @ark = Ark.where(:noid=>params[:noid])
    @annotation_object = Ark.where(:noid=>params[:annotation_object_id])
    redirect_to redirect_base + "/annotation/" + @annotation_object[0].namespace_id + ":" + @annotation_object[0].noid
  end

  def iiif_collection
    @ark = Ark.where(:noid=>params[:noid])
    redirect_to redirect_base + "/iiif_collection"
  end

  def iiif_search
    @ark = Ark.where(:noid=>params[:noid])
    iiif_query_params = request.query_parameters.to_query
    redirect_path = if iiif_query_params.empty?
                      redirect_base + "/iiif_search"
                    else
                      redirect_base + "/iiif_search?" + iiif_query_params
                    end
    redirect_to redirect_path
  end

  # PUT /arks/1
  # PUT /arks/1.json
  def update
    @ark = Ark.find(params[:id])

    respond_to do |format|
      if @ark.update_attributes(params[:ark])
        format.html { redirect_to @ark, notice: 'Ark was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @ark.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /arks/1
  # DELETE /arks/1.json
  def destroy
    @ark.delete = false
    if @ark.save
      head: :no_content
    else
      render json: {errors: @ark.errors}, status: :unprocessable_entity
    end
  end

  private
  def find_ark
    if params[:id]
      @ark = Ark.find(params[:id])
    elsif params[:noid]
      @ark.find_by(noid: params[:noid])
      raise ActiveRecord::RecordNotFound, "Unable to locate ark with identifier-#{params[:noid]}"
    end
  end

  def ark_params
    params.require(:ark).permit(:local_original_identifier, :local_original_identifier_type, :namespace_ark, :namespace_id, :url_base, :model_type, :parent_pid, secondary_parent_pids: [])
  end
end
