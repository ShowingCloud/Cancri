class Admin::DemeanorController < AdminController
  before_action :set_demeanor, only: [:show, :edit, :update, :destroy]

  # GET /admin/demeanor
  # GET /admin/demeanor.json
  def index
    @demeanor = Demeanor.all.page(params[:page]).per(params[:per])
  end

  # GET /admin/demeanor/1
  # GET /admin/demeanor/1.json
  def show
  end

  # GET /admin/demeanor/new
  def new
    @demeanor = Demeanor.new
  end

  # GET /admin/demeanor/1/edit
  def edit
  end

  # POST /admin/demeanor
  # POST /admin/demeanor.json
  def create
    params[:demeanor][:desc].each_with_index { |a, index|
      if index !=0
        @demeanor= Demeanor.create!(:desc => a, :competition_id => params[:demeanor][:competition_id], file_type: 1)
      end
    }

    # @demeanor = Demeanor.new(demeanor_params)
    respond_to do |format|
      if @demeanor.save

        format.html { redirect_to '/admin/demeanor', notice: '上传成功' }
        format.json { render action: 'show', status: :created, location: @demeanor }
      else
        format.html { render action: 'new' }
        format.json { render json: @demeanor.errors, status: :unprocessable_entity }
      end
    end


  end

  # PATCH/PUT /admin/demeanor/1
  # PATCH/PUT /admin/demeanor/1.json
  def update
    respond_to do |format|
      if @demeanor.update(demeanor_params)
        format.html { redirect_to [:admin, @demeanor], notice: '更新成功' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @demeanor.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/demeanor/1
  # DELETE /admin/demeanor/1.json
  def destroy
    @demeanor.destroy
    respond_to do |format|
      format.html { redirect_to admin_demeanor_url, notice: '删除成功' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_demeanor
    @demeanor = Demeanor.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def demeanor_params
    params.require(:demeanor).permit(:competition_id, {desc: []})
  end

end