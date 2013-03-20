class ArksController < ApplicationController
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
    @ark = Ark.new(params[:ark])
    #pid = Noid::Minter.new(:template => '.reeddeeddk').mint
    pid = IdService.mint(params[:ark][:namespace_id])
    @ark.pid = pid
    @ark.noid = IdService.getid(pid)
    @ark.view_object = ""
    @ark.view_thumbnail = "/preview/"


    respond_to do |format|
      if @ark.save
        #format.html { redirect_to @ark, notice: 'Ark was successfully created.' }
        format.json { render json: @ark.to_json, status: :created }
      else
        #format.html { render action: "new" }
        format.json { render json: @ark.errors, status: :unprocessable_entity }
      end
    end
  end

  def object_in_view
    puts "in object in view with pid: "  + params[:pid]
  end

  def thumbnail
    @ark = Ark.where(:noid=>params[:noid])


    redirect_to @ark[0].url_base + @ark[0].view_thumbnail + @ark[0].namespace_id + ":" + @ark[0].noid
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
end
