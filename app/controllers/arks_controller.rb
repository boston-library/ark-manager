class ArksController < ApplicationController
  beofre_action :find_ark, only: [:show, :destroy, :update]
  def show
    render json: @ark
  end

  def create
    Rails.logger.debug "Params of :ark are: #{params[:ark].inspect}"
    if ark_params[:parent_pid]
      Rails.logger.debug "Found parent pid"
      @ark = Ark.by_parent_pid(ark_params[:parent_pid]).by_local_original_identifier(ark_params[:local_original_identifier], ark_params[:local_original_identifier_type]).first
    else
      @ark = Ark.by_local_original_identifier(ark_params[:local_original_identifier], ark_params[:local_original_identifier_type]).first
    end

    if @ark.present?
      Rails.logger.debug "Found a matching ark! : " + @ark.to_s
      if @ark.deleted
        @ark.deleted = false
      end
    else
      @ark = Ark.new(ark_params)
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
    @ark.deleted = true
    @ark.save
  end

  def object_in_view
    redirect_to @ark.redirect_base_url
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
    @ark.deleted = true
    if @ark.save
      head: :no_content
    else
      render json: {errors: @ark.errors}, status: :unprocessable_entity
    end
  end

  private
  def find_ark
    @ark = Ark.find(params:[])
  end

  def ark_params
    params.require(:ark).permit(:local_original_identifier, :local_original_identifier_type, :namespace_ark, :namespace_id, :url_base, :model_type, :parent_pid, secondary_parent_pids: [])
  end
end
