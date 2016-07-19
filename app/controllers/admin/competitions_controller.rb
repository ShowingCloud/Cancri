class Admin::CompetitionsController < AdminController
  before_action :set_competition, only: [:show, :edit, :update, :destroy, :events, :workers]
  before_action do
    authenticate_permissions(['admin'])
  end

  # GET /admin/competitions
  # GET /admin/competitions.json
  def index
    if params[:field].present? && params[:keyword].present?
      @competitions = Competition.all.where(["#{params[:field]} like ?", "%#{params[:keyword]}%"]).page(params[:page]).per(params[:per])
    else
      @competitions = Competition.all.page(params[:page]).per(params[:per])
    end
  end

  def get_events
    if params[:parent_id].present?
      events = Event.where(competition_id: params[:id], parent_id: params[:parent_id], level: 2).select(:id, :name, :parent_id, :is_father)
    else
      events = Event.where(competition_id: params[:id], level: 1).select(:id, :name, :parent_id, :is_father)
    end
    render json: events
  end

  # def events
  #   @events = Event.find_by_sql("select a.id,a.name,group_concat(event_workers.user_id) as user_ids,count(event_workers.user_id) as worker_count from events a left join event_workers on a.id = event_workers.event_id where a.competition_id=#{params[:id]} and a.is_father=0 GROUP BY a.id").map { |e| {
  #       id: e.id,
  #       name: e.name,
  #       worker_count: e.worker_count,
  #       workers: e.user_ids.blank? ? nil : e.user_ids.split(',').map { |x| [x.to_i, UserProfile.find(x.to_i).username] }
  #   } }
  #   @events_workers = CompWorker.find_by_sql("select a.user_id as user_id,user_profiles.username as username from comp_workers a left join user_profiles on a.user_id = user_profiles.user_id where a.competition_id=#{params[:id]} and a.status=1 GROUP BY a.user_id")
  # end
  #
  # def workers
  #   @worker_events = CompWorker.find_by_sql("select a.user_id as user_id,group_concat(events.name) as events,count(event_workers.event_id) as count,user_profiles.username as username,count(event_workers.event_id) as eds, group_concat(event_workers.event_id) from comp_workers a left join event_workers on event_workers.user_id = a.user_id left join events on events.id = event_workers.event_id left join user_profiles on a.user_id = user_profiles.user_id where a.competition_id=#{params[:id]} and a.status=1 GROUP BY a.user_id")
  # end

  # def delete_event_worker
  #   if params[:ud].present? && params[:ed].present?
  #     ew = EventWorker.where(user_id: params[:ud], event_id: params[:ed]).take.delete
  #     if ew.delete
  #       result = [true, '删除成功']
  #     else
  #       result = [false, '删除失败']
  #     end
  #   else
  #     result=[false, '不规范操作']
  #   end
  #   render json: result
  # end
  #
  # def add_event_worker
  #   user_ids = params[:user_ids]
  #   ed = params[:ed]
  #   if user_ids.length == 0
  #     result = [false, '选择的裁判人数不能为零']
  #   else
  #     message = ''
  #     user_ids.each do |ud|
  #       ewe = EventWorker.where(event_id: ed, user_id: ud).exists?
  #       unless ewe
  #         ew = EventWorker.create!(event_id: ed, user_id: ud)
  #         if ew.save
  #           message = '添加成功' + message.to_s
  #         else
  #           message = '添加失败' + message.to_s
  #         end
  #       end
  #     end
  #     result = [true, message]
  #   end
  #   render json: result
  # end

  # GET /admin/competitions/1
  # GET /admin/competitions/1.json
  def show
    @users = User.where(validate_status: 1)
  end

  # GET /admin/competitions/new
  def new
    @competition = Competition.new
  end

  # GET /admin/competitions/1/edit
  def edit
  end

  # POST /admin/competitions
  # POST /admin/competitions.json
  def create
    @competition = Competition.new(competition_params)
    respond_to do |format|
      if @competition.save
        format.html { redirect_to [:admin, @competition], notice: '比赛创建成功.' }
        format.json { render action: 'show', status: :created, location: @competition }
      else
        format.html { render action: 'new' }
        format.json { render json: @competition.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /admin/competitions/1
  # PATCH/PUT /admin/competitions/1.json
  def update
    respond_to do |format|
      if @competition.update(competition_params)
        format.html { redirect_to [:admin, @competition], notice: '比赛更新成功' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @competition.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/competitions/1
  # DELETE /admin/competitions/1.json
  def destroy
    @competition.destroy
    respond_to do |format|
      format.html { redirect_to admin_competitions_url, notice: '比赛删除成功.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_competition
    @competition = Competition.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def competition_params
    params.require(:competition).permit!
  end
end
