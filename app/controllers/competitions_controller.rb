class CompetitionsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :invite]
  before_action :set_competition, only: [:show]
  layout 'invite', only: [:invite]

  def index
    @competitions = Competition.all
  end

  def show
    @events = Event.where(competition_id: @competition.id)
  end

  def apply_event
    @event = Event.find(params[:eid])
    @districts = District.all
    @teams = Team.includes(:team_user_ships).where(event_id: params[:eid])
    @already_apply = TeamUserShip.where(event_id: params[:eid], user_id: current_user.id).select(:team_id).take

  end

  def update_apply_info
    if params[:username].present? and params[:school].present? and params[:grade].present?
      user = UserProfile.find_by(user_id: current_user.id)
      if user.present?
        user.username = params[:username]
        user.age = params[:age]
        user.school = params[:school]
        user.grade = params[:grade]
        user.bj = params[:bj]
        if user.save
          status = true
          message = '个人信息确认成功'
        else
          status = false
          message = '个人信息更新失败'
        end
      else
        up = UserProfile.create!(user_id: current_user.id, username: params[:username], age: params[:age], school: params[:school], grade: params[:grade], bj: params[:bj])
        if up.save
          status = true
          message = '个人信息添加成功'
        else
          status = false
          message = '个人信息添加失败'
        end
      end
    else
      status = false
      message = '个人信息输入不完整'
    end
    render json: [status, message]
  end

  def leader_create_team
    user_id = current_user.id
    already_apply = TeamUserShip.where(user_id: user_id, event_id: params[:team_event]).exists?
    team_name = Team.where(event_id: params[:team_event], name: params[:team_name]).take
    if already_apply
      result = [false, '该比赛您已经报名，请不要再次报名!']
    elsif team_name.present?
      result = [false, '很抱歉，该比赛中队伍['+team_name.name+']已存在，请更改队伍名称!']
    else
      team = Team.create!(name: params[:team_name], district_id: params[:team_district], user_id: user_id, teacher: params[:team_teacher], event_id: params[:team_event], team_code: params[:team_code])
      if team.save
        team_user_ship = TeamUserShip.create!(team_id: team.id, user_id: team.user_id, event_id: params[:team_event])
        if team_user_ship.save
          result = [true, '队伍['+team.name+']创建成功!']
        else
          team.delete
          result = [false, '队伍创建失败']
        end
      else
        result = [false, '队伍创建失败']
      end
    end
    render json: result
  end

  def leader_invite_player
    if request.method == 'POST' && params[:invited_email].present?
      user = User.where(email: params[:invited_email]).exists?
      ## 未验证
      unless user
        code = SecureRandom.uuid.gsub('-', '')
        has_invited = Invite.where(email: params[:invited_email], invite_type: 'LEADER_INVITE').exists?
        if has_invited
          render json: [false, '已被邀请，请不要重复邀请']
        else
          invite_action = Invite.create!(email: params[:invited_email], code: code, invite_type: 'LEADER_INVITE', user_id: current_user.id, team_id: params[:td])
          if invite_action.save
            status = UserMailer.leader_invite_player(current_user.user_profile.username, params[:invited_email], code, params[:event_name], params[:team_name], params[:td]).deliver
            if status
              render json: [true, '邀请已经发送到'+params[:invited_email].to_s]
            else
              render json: [false, '邀请失败']
              invite_action.delete
            end
          end
        end
      end
    end
  end

  def invite

    invited_email = params[:email]
    invited_code = params[:code]
    # unless invited_code.present? && invited_email.present?
    #   flash[:notice]='不规范请求'
    #   redirect_to root_path
    # end
    @add_info = InvitePlayer.new
    if request.method == 'GET'
      if invited_email.present? && invited_code.present?
        @is_invite = Invite.where(email: invited_email, code: invited_code).joins(:team, :user_profile).where("teams.id = invites.team_id", "invites.user_id=user_profiles.user_id").select("teams.name as team_name", "user_profiles.username as leader", :email, :code).take
        if @is_invite.present?
          @add_info.leader = @is_invite.leader
          @add_info.team_name = @is_invite.team_name
        else
          flash[:notice] = '该链接已失效或不存在'
          redirect_to root_path
        end
      else
        flash[:notice]='不规范请求'
        redirect_to(root_path) and return
      end
    end

    if request.method == 'POST'
      nickname = params[:invite_player][:nickname]
      username = params[:invite_player][:username]
      grade = params[:invite_player][:grade]
      school = params[:invite_player][:school]
      email = params[:invite_player][:email]
      code = params[:invite_player][:code]
      @add_info = InvitePlayer.new(email: email, code: code, nickname: nickname, username: username, grade: grade, school: school, password: params[:invite_player][:password])
      if @add_info.save
        flash[:notice] = '您已成功加入此队'
        redirect_to root_path
      else
        render :invite
      end
    end
  end

  protected

  def set_competition
    @competition = Competition.find(params[:id])
  end
end
