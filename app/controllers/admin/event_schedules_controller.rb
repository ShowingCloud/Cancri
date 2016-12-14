class Admin::EventSchedulesController < AdminController
  before_action do
    authenticate_permissions(['admin'])
  end

  def edit
    id = params[:id]
    @event = Event.joins(:competition).where(id: id).select(:id, :name, 'competitions.name as comp_name', 'competitions.end_time as comp_end_time').take!
    @event_schedules = EventSchedule.left_joins(:schedule).where(event_id: id).select(:id, :event_id, :kind, :group, :is_show, 'schedules.name as schedule_name').order('event_schedules.group asc')
    if @event_schedules.present?
      @one_cs = EventSchedule.new(event_id: id)
      @event_schedule = @event_schedules
    else
      @event_schedule = EventSchedule.new(event_id: id)
    end
  end


  def create
    @event_schedule = EventSchedule.new(event_schedule_params)
    respond_to do |format|
      if @event_schedule.save
        format.html { redirect_to '/admin/event_schedules/'+@event_schedule.event_id.to_s+'/edit', notice: '比赛进程创建成功.' }
      else
        format.html { redirect_to "/admin/event_schedules/#{params[:event_schedule][:event_id]}/edit", alert: @event_schedule.errors.full_messages }
        format.json { render json: @event_schedule.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    es = EventSchedule.find(params[:esd])
    es.update_attributes!(kind: params[:kind])
    if es.save
      result = [true, '更改成功']
    else
      result = [false, '更改失败']
    end
    render json: result
  end

  def update_is_show
    is_show = params[:value]
    esd = params[:esd]
    if is_show && esd
      es = EventSchedule.find_by_id(esd)
      if es.present?
        if es.update_attributes(is_show: is_show)
          result= [true, '更新成功']
        else
          result = [false, '更新失败']
        end
      else
        result = [false, '不规范请求']
      end
    else
      result = [false, '参数不完整']
    end
    render json: {status: result[0], message: result[1]}
  end


  def destroy
    @event_schedule = EventSchedule.find(params[:id])
    @event_schedule.destroy
    respond_to do |format|
      format.html { redirect_to "/admin/event_schedules/#{@event_schedule.event_id.to_s}/edit", notice: '已成功删除.' }
      format.json { head :no_content }
    end
  end

  private


  # Never trust parameters from the scary internet, only allow the white list through.
  def event_schedule_params
    params.require(:event_schedule).permit!
  end

end
