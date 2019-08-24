class Admin::VideosController < AdminController
  before_action :set_video, only: [:show, :edit, :update, :destroy]
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
      @videos = Video.where(type_id: type_id).all.page(params[:page]).per(params[:per])
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
    # @demeanor = Video.new
    @video = Video.new
  end

  # GET /admin/demeanor/1/edit
  def edit
  end

  # POST /admin/demeanor
  # POST /admin/demeanor.json
  def create
    @video = Video.new(video_params)

    respond_to do |format|
      if @video.save

        format.html { redirect_to "/admin/videos", notice: '上传成功' }
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
      if @video.update(video_params)
        format.html { redirect_to "#{admin_video_url(@video)}", notice: '更新成功' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @video.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/demeanor/1
  # DELETE /admin/demeanor/1.json
  def destroy
    @video.destroy
    respond_to do |format|
      format.html { redirect_to "#{admin_videos_url}?type_id=#{@video.type_id}&type=#{@video.video_type}", notice: '删除成功' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_video
    @video = Video.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def video_params
    params.require(:video).permit(:type_id, :video, :video_type, :sort, :desc, :status)
  end
end