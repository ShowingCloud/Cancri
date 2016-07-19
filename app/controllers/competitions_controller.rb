class CompetitionsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :invite]
  before_action :set_competition, only: [:show]

  def index
    competitions = Competition.where.not(status: 0); false
    if params[:host_year].present?
      competitions = competitions.where(host_year: params[:host_year])
    end
    @competitions = competitions.select(:id, :name).order('id desc').page(params[:page]).per(params[:per])
  end

  def show
  end

  def apply_event
    if require_mobile
      @competition = Competition.where(id: params[:cd]).select(:name).take
      @events = Event.where(competition_id: params[:cd], is_father: false).select(:name, :id, :team_max_num)
      @user_info = UserProfile.left_joins(:school).where(user_id: current_user.id).select(:username, :student_code, :identity_card, :gender, :birthday, :district_id, 'schools.name', :grade, :bj).take
    else
      redirect_to "/competitions/#{params[:cd]}", notice: '继续操作前请添加手机信息'
    end
  end

  def already_apply
    if params[:ed].present?
      event = Event.find(params[:ed])
      if event.present?
        a_p = TeamUserShip.where(event_id: params[:ed], user_id: current_user.id).take
        if a_p.present?
          if a_p.status
            team_players = Team.find_by_sql("select t.user_id as id,a.team_id,u_p.username,u_p.bj,t.identifier,t.teacher,t.teacher_mobile,u_p.grade as grade,u_p.user_id as user_id,u_p.gender as gender, a.status,t.name as name,s.name as school from team_user_ships a INNER JOIN teams t on t.id = a.team_id inner join user_profiles u_p on u_p.user_id = a.user_id inner join schools s on s.id = u_p.school where a.team_id = #{a_p.team_id}")
            result =[true, team_players, event.group]
          else
            result = [false, '您已被邀请参加该项目,请去消息中心去处理']
          end
        else
          result = [false, '未报名', event.group]
        end
      else
        result=[false, '参数不合法']
      end
    else
      result=[false, '参数不完整']
    end
    render json: result
  end

  protected

  def set_competition
    @competition = Competition.find(params[:id])
  end
end
