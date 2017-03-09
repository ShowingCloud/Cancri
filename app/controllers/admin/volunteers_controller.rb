class Admin::VolunteersController < AdminController
  before_action :set_volunteer, only: [:show, :edit]
  before_action do
    authenticate_permissions(['editor', 'admin', 'super_admin'])
  end


  # GET /admin/volunteers
  # GET /admin/volunteers.json
  def index
    field = params[:field]
    keyword = params[:keyword]
    order_by = params[:order_by]
    order_with = order_by.in?(%w(points times)) ? "#{order_by} desc" : "username asc"

    volunteers = UserRole.joins(:user).left_joins(:user_profile).where(role_id: 3, status: 1).select(:id, :updated_at, :times, :points, 'users.mobile', 'user_profiles.username', 'user_profiles.standby_school', 'user_profiles.alipay_account').order(order_with)
    if field.in?(%w(standby_school username)) && keyword.present?
      volunteers = volunteers.where("user_profiles.#{field} like ?", "%#{keyword}%")
    end
    @volunteers = volunteers.page(params[:page]).per(params[:per])
  end

  # GET /admin/volunteers/1
  # GET /admin/volunteers/1.json
  def show
    @events = UserRole.lj_e_v_u_e_v.joins(:user_profile).where(id: params[:id], status: 1, role_id: 3).select(:id, :user_id, :points, :times, 'user_profiles.standby_school', 'user_profiles.username', 'e_v.name', 'e_v_u.point', 'e_v_u.updated_at', 'e_v_u.desc', 'e_v_u.status as e_v_u_status').page(params[:page]).per(params[:per])
    unless @events
      render_optional_error(404)
    end
  end

  # GET /admin/volunteers/new
  def new
  end

  # GET /admin/volunteers/1/edit
  def edit
  end

  def edit_regulation
    if request.method == 'POST'
      if regulation_params[:id].present?
        @regulation = Regulation.find(regulation_params[:id])
        @regulation.update(regulation_params)
      else
        @regulation = Regulation.new(regulation_params)
      end

      respond_to do |format|
        if @regulation.save
          format.html { redirect_to '/admin/volunteers/regulation', notice: '操作成功!' }
        else
          @volunteer_r = Regulation.new(regulation_params)
          flash[:alert] = @regulation.errors.full_messages.first
          format.html { render action: 'edit_regulation' }
        end
      end
    else
      @volunteer_r = Regulation.find_by_regulation_type(1) || Regulation.new
    end
  end

  def regulation
    @volunteer_r = Regulation.find_by_regulation_type(1)
  end


  # POST /admin/volunteers
  # POST /admin/volunteers.json
  def create
    @volunteer = UserRole.new(volunteer_params)

    respond_to do |format|
      if @volunteer.save
        format.html { redirect_to [:admin, @volunteer], notice: '创建成功!' }
        format.json { render action: 'show', status: :created, location: @volunteer }
      else
        format.html { render action: 'new' }
        format.json { render json: @volunteer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/volunteers/1
  # PATCH/PUT /admin/volunteers/1.json
  def update
    respond_to do |format|
      if @volunteer.update(volunteer_params)
        format.html { redirect_to [:admin, @volunteer], notice: '更新成功!' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @volunteer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/volunteers/1
  # DELETE /admin/volunteers/1.json
  def destroy
    @volunteer.destroy
    respond_to do |format|
      format.html { redirect_to admin_volunteers_index_url, notice: '删除成功' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_volunteer
    @volunteer = UserRole.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def volunteer_params
    params.require(:user_role).permit!
  end

  def regulation_params
    params.require(:regulation).permit(:id, :name, :regulation_type, :content)
  end

end