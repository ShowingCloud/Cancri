class Admin::NewsTypesController < AdminController
  before_action :set_news_type, only: [:show, :edit, :update]

  # GET /admin/news_types
  # GET /admin/news_types.json
  def index
    if params[:field].present? && params[:keyword].present?
      @news_types = NewsType.all.where(["#{params[:field]} like ?", "%#{params[:keyword]}%"]).page(params[:page]).per(params[:per])
    else
      @news_types = NewsType.all.page(params[:page]).per(params[:per])
    end
  end

  # GET /admin/news_types/1
  # GET /admin/news_types/1.json
  def show
  end

  # GET /admin/news_types/new
  def new
    @news_type = NewsType.new
  end

  # GET /admin/news_types/1/edit
  def edit
  end

  # POST /admin/news_types
  # POST /admin/news_types.json
  def create
    @news_type = NewsType.new(news_type_params)

    respond_to do |format|
      if @news_type.save
        format.html { redirect_to [:admin, @news_type], notice: '新闻类型创建成功!' }
        format.json { render action: 'show', status: :created, location: @news_type }
      else
        format.html { render action: 'new' }
        format.json { render json: @news_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/news_types/1
  # PATCH/PUT /admin/news_types/1.json
  def update
    respond_to do |format|
      if @news_type.update(news_type_params)
        format.html { redirect_to [:admin, @news_type], notice: '新闻类型更新成功!' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @news_type.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/news_types/1
  # DELETE /admin/news_types/1.json
  def destroy
    has_use = News.where("locate(#{params[:id]},news_type)>0").exists?
    if has_use
      @notice=[false, 0, '该类型已经被使用，不能删除']
    else
      @news_type=NewsType.find(params[:id])
      @news_type.destroy
      @notice=[true, @news_type.id, '新闻类型删除成功']
    end
    respond_to do |format|
      format.js
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_news_type
    @news_type = NewsType.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def news_type_params
    params.require(:news_type).permit(:name)
  end
end
