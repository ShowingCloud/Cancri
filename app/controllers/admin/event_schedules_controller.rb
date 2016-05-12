class Admin::EventSchedulesController < AdminController
  before_action do
    authenticate_permissions(['admin'])
  end

  def edit
    @event_schedules=EventSchedule.includes(:event, :schedule).where(event_id: params[:id])
    if @event_schedules.present?
      @one_cs = EventSchedule.new(event_id: params[:id])
      @event_schedule = @event_schedules
    else
      @event_schedule = EventSchedule.new(event_id: params[:id])
    end
  end


  def create

    @event_schedule = EventSchedule.new(event_schedule_params)
    respond_to do |format|
      if @event_schedule.save
        format.html { redirect_to '/admin/event_schedules/'+@event_schedule.event_id.to_s+'/edit', notice: '比赛进程创建成功.' }
      else
        format.html { redirect_to "/admin/event_schedules/#{params[:event_schedule][:event_id]}/edit", notice: @event_schedule.errors }
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
