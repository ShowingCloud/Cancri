class Admin::RolesController < AdminController
  before_action :set_role, only: [:show, :edit, :update]

  # GET /admin/roles
  # GET /admin/roles.json
  def index
    if params[:field].present? && params[:keyword].present?
      @roles = Role.all.where(["#{params[:field]} like ?", "%#{params[:keyword]}%"]).page(params[:page]).per(params[:per])
    else
      @roles = Role.all.page(params[:page]).per(params[:per])
    end

  end

  # GET /admin/roles/1
  # GET /admin/roles/1.json
  def show
  end

  # GET /admin/roles/new
  def new
    @role = Role.new
  end

  # GET /admin/roles/1/edit
  def edit
  end

  # POST /admin/roles
  # POST /admin/roles.json
  def create
    @role = Role.new(role_params)

    respond_to do |format|
      if @role.save
        format.html { redirect_to [:admin, @role], notice: '角色创建成功' }
        format.json { render action: 'show', status: :created, location: @role }
      else
        format.html { render action: 'new' }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/roles/1
  # PATCH/PUT /admin/roles/1.json
  def update
    respond_to do |format|
      if @role.update(role_params)
        format.html { redirect_to [:admin, @role], notice: '角色更新成功' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @role.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/roles/1
  # DELETE /admin/roles/1.json
  def destroy
    has_use = UserRole.where(role_id: params[:id]).exists?
    if has_use
      @notice=[false, 0, '该角色已经被使用，不能删除']
    else
      @role = Role.find(params[:id])
      @role.destroy
      @notice=[true, @role.id, '新闻类型删除成功']
    end
    respond_to do |format|
      format.js
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_role
    @role = Role.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def role_params
    params.require(:role).permit(:name)
  end
end
