class ArksController < ApplicationController

  skip_before_filter :verify_authenticity_token

  # GET /arks
  # GET /arks.json
  def index
    @arks = Ark.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @arks }
    end
  end

  # GET /arks/1
  # GET /arks/1.json
  def show
    @ark = Ark.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @ark }
    end
  end

  # GET /arks/new
  # GET /arks/new.json
  def new
    @ark = Ark.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @ark }
    end
  end

  # GET /arks/1/edit
  def edit
    @ark = Ark.find(params[:id])
  end

  # POST /arks
  # POST /arks.json
  def create
    logger.debug "Params of :ark are: " + params[:ark].to_s
    if params[:ark][:parent_pid]
      logger.debug "Found parent pid"
      @ark = Ark.where(:local_original_identifier=>params[:ark][:local_original_identifier], :local_original_identifier_type=>params[:ark][:local_original_identifier_type], :parent_pid=>params[:ark][:parent_pid])
    else
      @ark = Ark.where(:local_original_identifier=>params[:ark][:local_original_identifier], :local_original_identifier_type=>params[:ark][:local_original_identifier_type])
    end

    if @ark.length == 1 && params[:ark][:local_original_identifier] != nil && params[:ark][:local_original_identifier] != ""
      @ark = @ark[0]
      logger.debug "Found a matching ark! : " + @ark.to_s
    else
      pid = IdService.mint(params[:ark][:namespace_id])
      ark_parameters = ActionController::Parameters.new(ark: {})
      ark_parameters[:ark][:local_original_identifier] = params[:ark][:local_original_identifier]
      ark_parameters[:ark][:local_original_identifier_type] = params[:ark][:local_original_identifier_type]
      ark_parameters[:ark][:namespace_ark] = params[:ark][:namespace_ark]
      ark_parameters[:ark][:namespace_id] = params[:ark][:namespace_id]
      ark_parameters[:ark][:url_base] = params[:ark][:url_base]
      ark_parameters[:ark][:model_type] = params[:ark][:model_type]
      ark_parameters[:ark][:pid] = pid
      ark_parameters[:ark][:noid] = IdService.getid(pid)
      ark_parameters[:ark][:view_object] = "/search/"
      ark_parameters[:ark][:view_thumbnail] = "/preview/"
      ark_parameters[:ark][:parent_pid] = params[:ark][:parent_pid]

      @ark = Ark.new(ark_params(ark_parameters))

      logger.debug "Made a new ark! : " + @ark.to_s
=begin
      @ark = Ark.new(params[:ark])
      pid = IdService.mint(params[:ark][:namespace_id])
      @ark.pid = pid
      @ark.noid = IdService.getid(pid)
      @ark.view_object = "/search/"
      @ark.view_thumbnail = "/preview/"
      @ark.parent_pid = params[:ark][:parent_pid]
=end
    end


    respond_to do |format|
      if @ark.save
        #format.html { redirect_to @ark, notice: 'Ark was successfully created.' }
        format.json { render json: @ark.to_json, status: :created }
      else
        #format.html { render action: "new" }
        logger.debug "Errors! : " + @ark.errors
        format.json { render json: @ark.errors, status: :unprocessable_entity }
      end
    end
  end

  def delete_ark
    @ark = Ark.where(:noid=>params[:ark][:pid])
    @ark.deleted = true
    @ark.save
  end


  def object_in_view
    @ark = Ark.where(:noid=>params[:noid])
    redirect_to @ark[0].url_base + @ark[0].view_object + @ark[0].namespace_id + ":" + @ark[0].noid
    #puts "in object in view with pid: "  + params[:pid]
  end

  def thumbnail
    @ark = Ark.where(:noid=>params[:noid])
    redirect_to @ark[0].url_base + @ark[0].view_thumbnail + @ark[0].namespace_id + ":" + @ark[0].noid
  end

  # TODO? move 'full_image' path into the data model
  def full_image
    @ark = Ark.where(:noid=>params[:noid])
    redirect_to @ark[0].url_base + '/full_image/' + @ark[0].namespace_id + ":" + @ark[0].noid
  end

  # TODO? move 'large_image' path into the data model
  def large_image
    @ark = Ark.where(:noid=>params[:noid])
    redirect_to @ark[0].url_base + '/large_image/' + @ark[0].namespace_id + ":" + @ark[0].noid
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
    @ark = Ark.find(params[:id])
    @ark.destroy

    respond_to do |format|
      format.html { redirect_to arks_url }
      format.json { head :no_content }
    end
  end

  def ark_params(hashed_params)
    hashed_params.require(:ark).permit(:local_original_identifier, :local_original_identifier_type, :namespace_ark, :namespace_id, :url_base, :model_type, :pid, :noid, :view_object, :view_thumbnail, :parent_pid)
  end
end
