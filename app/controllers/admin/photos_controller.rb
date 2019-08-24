class Admin::PhotosController < AdminController
  before_action :set_photo, only: [:show, :edit, :update, :destroy]
  # before_action :set_video, only: [:show, :edit, :update, :destroy]

  # GET /admin/demeanor
  # GET /admin/demeanor.json
  def index
    type = params[:type]
    type_id = params[:type_id]
    if type.present?
      case type
        when '0' then
          @model_type = Competition.find(type_id)
        when '1' then
          @model_type = Activity.find(type_id)
        else
          render_optional_error(404)
      end
      @photos = Photo.where(type_id: type_id).page(params[:page]).per(params[:per])
    else
      render_optional_error(404)
    end
  end

  # GET /admin/demeanor/1
  # GET /admin/demeanor/1.json
  def show
  end

  # GET /admin/demeanor/new
  def new
    @photo = Photo.new
  end

  # GET /admin/demeanor/1/edit
  def edit
  end

  # POST /admin/demeanor
  # POST /admin/demeanor.json
  def create
    @photo = Photo.new(photo_params)

    respond_to do |format|
      if @photo.save

        format.html { redirect_to "/admin/photos", notice: '上传成功' }
        format.js
      else
        format.html { render action: 'new' }
        format.js
      end
    end
  end

  # PATCH/PUT /admin/demeanor/1
  # PATCH/PUT /admin/demeanor/1.json
  def update
    respond_to do |format|
      if @photo.update(photo_params)
        format.html { redirect_to "#{admin_photo_url(@photo)}", notice: '更新成功' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/demeanor/1
  # DELETE /admin/demeanor/1.json
  def destroy
    @photo.destroy
    respond_to do |format|
      format.html { redirect_to "#{admin_photos_url}?type_id=#{@photo.type_id}&type=#{@photo.photo_type}", notice: '删除成功' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_photo
    @photo = Photo.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def photo_params
    params.require(:photo).permit(:type_id, :image, :photo_type, :sort, :desc, :status)
  end

end