class Admin::EventVolunteersController < AdminController
  before_action :set_event_volunteer, only: [:show, :edit, :update]
  before_action do
    authenticate_permissions(['editor', 'admin', 'super_admin'])
  end

  # GET /admin/event_volunteers
  # GET /admin/event_volunteers.json
  def index
    roles = EventVolunteer.all
    if params[:field].present? && params[:keyword].present?
      roles = roles.where(["#{params[:field]} like ?", "%#{params[:keyword]}%"])
    end
    @event_volunteers = roles.page(params[:page]).per(params[:per])
  end

  # GET /admin/event_volunteers/1
  # GET /admin/event_volunteers/1.json
  def show
  end

  # GET /admin/event_volunteers/new
  def new
    @event_volunteer = EventVolunteer.new
  end

  # GET /admin/event_volunteers/1/edit
  def edit
  end

  # POST /admin/event_volunteers
  # POST /admin/event_volunteers.json
  def create
    @event_volunteer = EventVolunteer.new(event_volunteer_params)

    respond_to do |format|
      if @event_volunteer.save
        format.html { redirect_to [:admin, @event_volunteer], notice: '创建成功' }
        format.json { render action: 'show', status: :created, location: @event_volunteer }
      else
        format.html { render action: 'new' }
        format.json { render json: @event_volunteer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/event_volunteers/1
  # PATCH/PUT /admin/event_volunteers/1.json
  def update
    respond_to do |format|
      if @event_volunteer.update(event_volunteer_params)
        format.html { redirect_to [:admin, @event_volunteer], notice: '更新成功' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @event_volunteer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/event_volunteers/1
  # DELETE /admin/event_volunteers/1.json
  def destroy
    event_volunteer_id = params[:id]
    has_use = EventVolunteerUser.where(event_volunteer_id: event_volunteer_id).exists?
    if has_use
      notice = {status: false, message: '已经有志愿者申请，不能删除'}
    else
      event_volunteer = EventVolunteer.find(event_volunteer_id)
      if event_volunteer.destroy
        notice = {status: true, obj_id: event_volunteer_id, message: '删除成功'}
      else
        notice = {status: false, message: '删除失败'}
      end
    end
    @notice = notice
    respond_to do |format|
      format.js
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_event_volunteer
    @event_volunteer = EventVolunteer.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def event_volunteer_params
    params.require(:event_volunteer).permit!
  end

end