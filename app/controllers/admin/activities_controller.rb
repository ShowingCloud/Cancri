class Admin::ActivitiesController < AdminController

  before_action do
    authenticate_permissions(['admin', 'editor', 'super_admin'])
  end
  before_action :set_activity, only: [:show, :edit, :update, :destroy, :users]

  # GET /admin/activities
  # GET /admin/activities.json
  def index
    activities = Activity.includes(:parent_activity).order('id desc'); false
    if params[:field].present? && params[:keyword].present?
      activities = activities.where(["activities.#{params[:field]} like ?", "%#{params[:keyword]}%"])
    end
    @activities= activities.page(params[:page]).per(params[:per])
  end

  # GET /admin/activities/1
  # GET /admin/activities/1.json
  def show
  end

  # GET /admin/activities/new
  def new
    @activity = Activity.new
  end

  # GET /admin/activities/1/edit
  def edit
  end

  def users
    field = params[:field]
    keyword = params[:keyword]
    users = @activity.activity_user_ships.left_joins(:school, :user).joins('left join user_profiles u_p on u_p.user_id = activity_user_ships.user_id'); false
    if field.present? && keyword.present?
      case field
        when 'school_name' then
          users = users.where(["schools.name like ?", "%#{keyword}%"])
        when 'username' then
          users = users.where(["u_p.username like ?", "%#{keyword}%"])
        when 'mobile' then
          users = users.where(["users.mobile like ?", "%#{keyword}%"])
        else
          render_optional_error(404)
      end
    end
    @users = users.select(:id, :user_id, :has_join, :score, 'u_p.username', 'users.mobile', 'schools.name as school_name', 'activity_user_ships.grade').order('school_name').page(params[:page]).per(params[:per])
  end

  def update_user_score
    aud = params[:aud]
    score = params[:score]
    if aud.present? && score.present?
      a_u = ActivityUserShip.find(aud)
      a_u.score = score
      if a_u.save
        result = [true, '打分成功']
      else
        result = [false, '打分失败']
      end
    else
      result = [false, '参数不完整']
    end
    render json: result
  end

  # POST /admin/activities
  # POST /admin/activities.json
  def create
    @activity = Activity.new(activity_params)

    respond_to do |format|
      if @activity.save
        format.html { redirect_to [:admin, @activity], notice: '活动创建成功' }
        format.json { render action: 'show', status: :created, location: @activity }
      else
        format.html { render action: 'new' }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/activities/1
  # PATCH/PUT /admin/activities/1.json
  def update
    respond_to do |format|
      if @activity.update(activity_params)
        format.html { redirect_to [:admin, @activity], notice: '活动更新成功' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/activities/1
  # DELETE /admin/activities/1.json
  def destroy
    @activity.destroy
    respond_to do |format|
      format.html { redirect_to admin_activities_url, notice: '活动删除成功' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_activity
    @activity = Activity.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def activity_params
    params.require(:activity).permit!
  end
end
