class Admin::VideosController < AdminController
  before_action :set_video, only: [:show, :edit, :update, :destroy]
  # before_action :set_video, only: [:show, :edit, :update, :destroy]

  # GET /admin/demeanor
  # GET /admin/demeanor.json
  def index
    @competition = Competition.find(params[:cod])
    @videos = Video.where(competition_id: params[:cod]).all.page(params[:page]).per(params[:per])
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

        format.html { redirect_to "/admin/videos?cod=#{@video.competition_id}", notice: '上传成功' }
        format.json { render action: 'show', status: :created, location: @video }
      else
        format.html { render action: 'new' }
        format.json { render json: @video.errors, status: :unprocessable_entity }
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
      format.html { redirect_to "#{admin_videos_url}?cod=#{params[:cod]}", notice: '删除成功' }
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
    params.require(:video).permit(:competition_id, :video, :sort, :desc, :status)
  end
end