class Admin::CompetitionSchedulesController < AdminController


  def new
    @comp_schedule = CompetitionSchedule.new
  end

  def edit
    comp_schedule=CompetitionSchedule.includes(:competition).where(competition_id: params[:id]).order('start_time asc')
    if comp_schedule.present?
      @one_cs = CompetitionSchedule.new #(competition_id: params[:id])
      @comp_schedule = comp_schedule
    else

      @comp_schedule = CompetitionSchedule.new
    end
  end


  def create
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


  def update

  end


  def destroy

  end

  private


  # Never trust parameters from the scary internet, only allow the white list through.
  def comp_schedule_params
    params.require(:competition_schedule).permit!
  end

end
