class Admin::UsersController < AdminController
  before_action :set_user, only: [:edit, :update, :destroy]

  # GET /admin/users
  # GET /admin/users.json
  def index
    field = params[:field]
    keyword = params[:keyword]
    users = User.joins('left join user_profiles on user_profiles.user_id = users.id').joins('left join schools s on s.id = user_profiles.school_id').order('id asc').select(:id, :nickname, :mobile, :email, :sign_in_count, :current_sign_in_at, 'user_profiles.username', 's.name as school_name'); false
    if field.present? && keyword.present?
      if field == 'username'
        users = users.where('user_profiles.username like ?', "%#{keyword}%")
      elsif field == 'school_name'
        users = users.where('s.name like ?', "%#{keyword}%")
      else
        users = users.where(["#{field} like ?", "%#{keyword}%"])
      end
    end
    @users = users.page(params[:page]).per(params[:per])
  end

  # GET /admin/users/1
  # GET /admin/users/1.json
  def show
    @user = User.left_joins(:user_profile).where(id: params[:id]).select(:id, :nickname, :mobile, :email,'user_profiles.username', 'user_profiles.gender','user_profiles.grade','user_profiles.bj','user_profiles.student_code','user_profiles.birthday').take!
  end

  # GET /admin/users/new
  def new
    @user = User.new
    @user.user_profile = @user.build_user_profile
  end

  # GET /admin/users/1/edit
  def edit
    unless @user.user_profile.present?
      @user.user_profile = @user.build_user_profile
    end
  end

  # POST /admin/users
  # POST /admin/users.json
  def create
    @user = User.new(user_params)
    @user_profile = @user.build_user_profile.update(user_profile_params)

    respond_to do |format|
      if @user.save && @user_profile
        format.html { redirect_to [:admin, @user], notice: t('activerecord.models.user') + ' 已成功创建.' }
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/users/1
  # PATCH/PUT /admin/users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params) && @user.user_profile.update(user_profile_params)
        format.html { redirect_to [:admin, @user], notice: t('activerecord.models.user') + ' 已成功更新.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/users/1
  # DELETE /admin/users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to admin_users_url, notice: t('activerecord.models.user') + ' 已成功删除.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:username, :nickname, :mobile, :email)
  end

  def user_profile_params
    params.require(:user_profile).permit(:username, :birthday, :gender, :grade, :student_code, :bj, :status)
  end
end
