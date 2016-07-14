class Admin::PhotosController < AdminController
  before_action :set_photo, only: [:show, :edit, :update, :destroy]
  # before_action :set_video, only: [:show, :edit, :update, :destroy]

  # GET /admin/demeanor
  # GET /admin/demeanor.json
  def index
    @competition = Competition.where(id: params[:cod]).select(:id, :name).take
    unless @competition
      raise ActiveRecord::RecordNotFound
    end
    if params[:field].present? && params[:keyword].present?
      @photos = Photo.where(competition_id: params[:cod]).where(["#{params[:field]} like ?", "%#{params[:keyword]}%"]).page(params[:page]).per(params[:per])
    else
      @photos = Photo.where(competition_id: params[:cod]).all.page(params[:page]).per(params[:per])
    end
  end

  # GET /admin/demeanor/1
  # GET /admin/demeanor/1.json
  def show
  end

  # GET /admin/demeanor/new
  def new
    # @demeanor = Video.new
    @photo = Photo.new
  end

  # GET /admin/demeanor/1/edit
  def edit
  end

  # POST /admin/demeanor
  # POST /admin/demeanor.json
  def create
    # images = params[:photo][:image]
    # if images.length > 0 && images.length<11
    params[:photo][:image].each_with_index { |a, index|
      @photo= Photo.create(:image => a, :competition_id => params[:photo][:competition_id])
    }
    # end


    respond_to do |format|
      if @photo.save
        format.html { redirect_to "/admin/photos?cod=#{@photo.competition_id}", notice: '上传成功' }
        format.json { render action: 'show', status: :created, location: @photo }
      else
        format.html { render action: 'new' }
        format.json { render json: @photo.errors, status: :unprocessable_entity }
      end
    end

    # p_attr = params[:demeanor]
    # puts 'nihao'
    # print p_attr
    # p_attr[:desc] = params[:demeanor][:desc].first if params[:demeanor][:desc].class == Array
    #
    # @demeanor = Demeanor.new(p_attr)
    # params[:demeanor][:desc].each_with_index { |a, index|
    #   if index !=0
    #     @demeanor= Demeanor.create!(:desc => a, :competition_id => 1, file_type: 1)
    #   end
    # }
    #
    # if @demeanor.save
    #   respond_to do |format|
    #     format.html {
    #       render :json => [@demeanor.to_jq_upload].to_json,
    #              :content_type => 'text/html',
    #              :layout => false
    #     }
    #     format.json {
    #       render :json => {:files => [@demeanor.to_jq_upload]}
    #     }
    #   end
    # else
    #   render :json => [{:error => "custom_failure"}], :status => 304
    # end


  end

  # PATCH/PUT /admin/demeanor/1
  # PATCH/PUT /admin/demeanor/1.json
  def update
    respond_to do |format|
      if @photo.update(photo_param)
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
      format.html { redirect_to "#{admin_photos_url}?cod=#{params[:cod]}", notice: '删除成功' }
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
    params.require(:photo).permit(:competition_id, {image: []}, :sort, :desc, :status)
  end

  def photo_param
    params.require(:photo).permit!
  end

end