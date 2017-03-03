class Admin::EventVolunteersController < AdminController
  before_action :authenticate
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

  def volunteer_detail
    user_id = params[:id]
    @events = EventVolunteer.lj_e_v_u_u_p_u_r.where('e_v_u.user_id=?', user_id).where('e_v_u.status=?', 1).select(:id, :name, :event_type, :type_id, 'e_v_u.desc', 'e_v_u.point', 'e_v_u.updated_at', 'u_p.username', 'u_p.standby_school', 'u_r.points', 'u_r.times').page(params[:page]).per(params[:per])
  end

  def volunteer_list
    id = params[:id]
    @volunteers = EventVolunteer.lj_e_v_u_u_p_u_r.joins('left join users u on u.id = u_p.user_id').where(id: id).select('e_v_u.id', :name, :event_type, :type_id, :positions, 'e_v_u.user_id', 'e_v_u.status', 'u.mobile', 'u_p.username', 'u_p.standby_school', 'e_v_u.status', 'e_v_u.point', 'e_v_u.desc', 'u_p.alipay_account', 'u_r.id as role_id', 'u_r.points', 'u_r.times').page(params[:page]).per(params[:per])
  end


  def audit_event_v_user
    status = params[:status]
    position = params[:position]
    event_id = params[:event_id]
    event_name = params[:event_name]
    e_v_u_id = params[:e_v_u_id]
    if status.in?(%w(1 0)) && e_v_u_id
      e_v_u = EventVolunteerUser.joins(:event_volunteer).where(id: e_v_u_id).select(:id, :name, :event_volunteer_id, :user_id, :status,:point, 'event_volunteers.event_type').take
      if e_v_u
        if e_v_u.status == 0
          if status == '0'
            if e_v_u.destroy
              CreateNotificationJob.perform_later ({user_id: e_v_u.user_id, message_type: 5, content: "感谢您申请#{e_v_u.name}，很抱歉未能录用"})
              result = [true, '审核成功，将消息推送告知被录用者']
            else
              result = [false, '审核失败']
            end
          else
            if position.present?
              if e_v_u.event_type == 'Activity' || (e_v_u.event_type == 'Competition' && event_id.to_i != 0)
                if e_v_u.update_attributes(event_id: event_id, status: 1, position: 1, point: nil)
                  result = [true, '录用成功，将消息推送告知被录用者']
                  CreateNotificationJob.perform_later ({user_id: e_v_u.user_id, message_type: 5, content: "您通过了在#{e_v_u.name}中的申请，职位为：#{event_name.present? ? event_name+' - ' : ''}#{position},请及时参加培训和活动！"})
                else
                  result = [false, '审核失败']
                end
              else
                result = [false, '该活动是比赛，请选择分配的项目']
              end
            else
              result = [false, '请选择职位']
            end
          end
        else
          result = [false, '该对象不在审核状态']
        end
      else
        result = [false, '对象不存在']
      end
    else
      result = [false, '参数不规范或不完整']
    end
    render json: {status: result[0], message: result[1]}
  end

  def update_e_v_u_info
    e_v_u_id = params[:e_v_u_id]
    point = params[:point]
    desc = params[:desc]

    if e_v_u_id.present? && point.present?
      e_v_u = EventVolunteerUser.where(id: e_v_u_id).take
      if e_v_u.present?
        if e_v_u.update_attributes(point: point, desc: desc)
          result = [true, '更新成功']
        else
          result = [false, '更新失败']
        end
      else
        result = [false, '该对象不存在']
      end
    else
      result = [false, '参数不完整']
    end
    render json: {status: result[0], message: result[1]}
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_event_volunteer
    @event_volunteer = EventVolunteer.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def event_volunteer_params
    params.require(:event_volunteer).permit(:name, :event_type, :type_id, :content, :apply_start_time, :apply_end_time, :status, :positions)
  end

end