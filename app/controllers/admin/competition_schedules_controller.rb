class Admin::CompetitionSchedulesController < AdminController
  before_action do
    authenticate_permissions(['admin', 'super_admin', 'edit'])
  end

  def edit
    id = params[:id]
    @comp_schedules=CompetitionSchedule.includes(:competition).where(competition_id: id).order('start_time asc').order('end_time asc')
    if @comp_schedules.present?
      @one_cs = CompetitionSchedule.new(competition_id: id)
      @comp_schedule = @comp_schedules
    else
      @comp_schedule = CompetitionSchedule.new(competition_id: id)
    end
  end


  def create
    @comp_schedule = CompetitionSchedule.new(comp_schedule_params)
    respond_to do |format|
      if @comp_schedule.save
        format.html { redirect_to '/admin/competition_schedules/'+@comp_schedule.competition_id.to_s+'/edit', notice: '比赛进程创建成功.' }
      else
        format.html { redirect_to '/admin/competition_schedules/'+comp_schedule_params[:competition_id].to_s+'/edit', notice: @comp_schedule.errors.full_messages.first }
        format.json { render json: @comp_schedule.errors, status: :unprocessable_entity }
      end
    end
  end


  def update_cs
    cs = CompetitionSchedule.find(params[:sd])
    cs.update_attributes(name: params[:name], start_time: params[:start_time], end_time: params[:end_time])
    if cs.save
      result = {status: true, message: '更改成功', end_time: cs.end_time.try(:strftime, '%Y-%m-%d %H:%M')}
    else
      result = {status: false, message: cs.errors.full_messages.first}
    end
    render json: result
  end


  def destroy
    @comp_schedule = CompetitionSchedule.find(params[:id])
    if @comp_schedule.destroy
      @notice = {status: true, message: '删除成功', id: @comp_schedule.id}
    else
      @notice = {status: false, message: '删除失败'}
    end
    respond_to do |format|
      format.html { redirect_to "/admin/competition_schedules/#{@comp_schedule.competition_id.to_s}/edit", notice: '已成功删除.' }
      format.json { head :no_content }
      format.js
    end
  end

  private


  # Never trust parameters from the scary internet, only allow the white list through.
  def comp_schedule_params
    params.require(:competition_schedule).permit!
  end

end
