class Admin::SchoolsController < AdminController

  before_action :set_school, only: [:edit, :update, :destroy]
  before_action do
    authenticate_permissions(['editor', 'admin', 'super_admin'])
  end
  # GET /admin/schools
  # GET /admin/schools.json
  def index
    schools = School.left_joins(:district).where(status: 1).select(:id, :name, :status, :user_add, :teacher_role, 'districts.name as district_name').order('district_id asc'); false
    if params[:field].present? && params[:keyword].present?
      schools = schools.where(["#{params[:field]} like ?", "%#{params[:keyword]}%"])
    end
    @schools = schools.page(params[:page]).per(params[:per])

    respond_to do |format|
      format.html
      format.xls {
        data = @schools.map { |x| {
            名称: x.name,
            区县: x.district_name

        } }
        filename = "School-Export-#{Time.now.strftime("%Y%m%d%H%M%S")}.xls"
        send_data(data.to_xls, :type => "text/xls;charset=utf-8,header=present", :filename => filename)
      }
    end
  end

  # GET /admin/schools/1
  # GET /admin/schools/1.json
  def show
    @school = School.left_joins(:district).where(id: params[:id]).select(:id, :name, 'districts.name as district_name').take
    unless @school
      render_optional_error(404)
    end
  end

  # GET /admin/schools/new
  def new
    @school = School.new
  end

  # GET /admin/schools/1/edit
  def edit
  end

  # POST /admin/schools
  # POST /admin/schools.json
  def create
    @school = School.new(school_params)

    respond_to do |format|
      if @school.save
        format.html { redirect_to [:admin, @school], notice: '学校创建成功!' }
        format.json { render action: 'show', status: :created, location: @school }
      else
        format.html { render action: 'new' }
        format.json { render json: @school.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/schools/1
  # PATCH/PUT /admin/schools/1.json
  def update
    respond_to do |format|
      if @school.update(school_params)
        format.html { redirect_to [:admin, @school], notice: '学校更新成功!' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @school.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/schools/1
  # DELETE /admin/schools/1.json
  def destroy
    @school.destroy
    respond_to do |format|
      format.html { redirect_to admin_schools_index_url, notice: '学校删除成功' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_school
    @school = School.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def school_params
    params.require(:school).permit!
  end
end