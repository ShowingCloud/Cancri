class Admin::VolunteersController < AdminController
  before_action :set_volunteer, only: [:show, :edit, :update, :destroy]

  # GET /admin/volunteers
  # GET /admin/volunteers.json
  def index
    if params[:field].present? && params[:keyword].present?
      @volunteers = Volunteer.all.where(["#{params[:field]} like ?", "%#{params[:keyword]}%"]).page(params[:page]).per(params[:per])
    else
      @volunteers = Volunteer.all.page(params[:page]).per(params[:per])
    end

  end

  # GET /admin/volunteers/1
  # GET /admin/volunteers/1.json
  def show
  end

  # GET /admin/volunteers/new
  def new
    @volunteer = Volunteer.new
  end

  # GET /admin/volunteers/1/edit
  def edit
  end

  # POST /admin/volunteers
  # POST /admin/volunteers.json
  def create
    @volunteer = Volunteer.new(volunteer_params)

    respond_to do |format|
      if @volunteer.save
        format.html { redirect_to [:admin, @volunteer], notice: '志愿者创建成功.' }
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
        format.html { redirect_to [:admin, @volunteer], notice: '志愿者更新成功.' }
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
      format.html { redirect_to admin_volunteers_url, notice: '志愿者删除成功.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_volunteer
    @volunteer = Volunteer.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def volunteer_params
    params.require(:volunteer).permit!
  end
end
