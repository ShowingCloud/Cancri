class Admin::CompetitionSchedulesController < AdminController

  def edit
    @comp_schedules=CompetitionSchedule.includes(:competition).where(competition_id: params[:id]).order('start_time asc').order('end_time asc')
    if @comp_schedules.present?
      @one_cs = CompetitionSchedule.new(competition_id: params[:id])
      @comp_schedule = @comp_schedules
    else
      @comp_schedule = CompetitionSchedule.new(competition_id: params[:id])
    end
  end


  def create
    if comp_schedule_params[:start_time].present? && comp_schedule_params[:start_time].split(':')[0].length < 2
      comp_schedule_params[:start_time] = '0'+comp_schedule_params[:start_time]
    end
    if comp_schedule_params[:end_time].present? && comp_schedule_params[:end_time].split(':')[0].length < 2
      comp_schedule_params[:end_time] = '0'+comp_schedule_params[:end_time]
    end
    @comp_schedule = CompetitionSchedule.new(comp_schedule_params)
    respond_to do |format|
      if @comp_schedule.save
        format.html { redirect_to '/admin/competition_schedules/'+@comp_schedule.competition_id.to_s+'/edit', notice: '比赛进程创建成功.' }
      else
        format.html { render action: 'new' }
        format.json { render json: @comp_schedule.errors, status: :unprocessable_entity }
      end
    end
  end


  def update_cs
    if params[:start_time].present? && params[:start_time].split(':')[0].length < 2
      params[:start_time] = '0'+params[:start_time]
    end
    if params[:end_time].present? && params[:end_time].split(':')[0].length < 2
      params[:end_time] = '0'+params[:end_time]
    end
    cs = CompetitionSchedule.find(params[:sd])
    cs.update_attributes!(name: params[:name], start_time: params[:start_time], end_time: params[:end_time])
    if cs.save
      result = [true, '更改成功']
    else
      result = [false, '更改失败']
    end
    render json: result
  end


  def destroy
    @comp_schedule = CompetitionSchedule.find(params[:id])
    @comp_schedule.destroy
    respond_to do |format|
      format.html { redirect_to "/admin/competition_schedules/#{@comp_schedule.competition_id.to_s}/edit", notice: '已成功删除.' }
      format.json { head :no_content }
    end
  end

  private


  # Never trust parameters from the scary internet, only allow the white list through.
  def comp_schedule_params
    params.require(:competition_schedule).permit!
  end

end
