class CompetitionsController < ApplicationController
  before_action :require_user, except: [:index, :show, :invite]
  before_action :set_competition, only: [:show]
  layout 'invite', only: [:invite]

  def index
    @competitions = Competition.all
  end

  def show
  end

  def apply_event
    if require_mobile_or_email
      @competition = Competition.find(params[:cd])
      @events = Event.where(competition_id: params[:cd], is_father: false).select(:name, :id, :team_max_num)
      #   @teams = Team.includes(:team_user_ships).where(event_id: params[:eid])
      #   @already_apply = TeamUserShip.includes(:team).where(event_id: params[:eid], user_id: current_user.id).take
      #   if @already_apply.present?
      #     @team_players = TeamUserShip.where(team_id: @already_apply.team_id).count
      #   end
    else
      redirect_to "/competitions/#{params[:cd]}", notice: '继续操作前请验证手机或邮箱'
    end
  end

  def already_apply
    if params[:ed].present?
      a_p = TeamUserShip.where(event_id: params[:ed], user_id: current_user.id).take
      if a_p.present?
        team_players = Team.find_by_sql("select a.id,u_p.username,u_p.grade as grade,u_p.user_id as user_id,u_p.gender as gender, a.status,t.name as name,s.name as school from team_user_ships a INNER JOIN teams t on t.id = a.team_id inner join user_profiles u_p on u_p.user_id = a.user_id inner join schools s on s.id = u_p.school where a.team_id = #{a_p.team_id}")
        result =[true, team_players, a_p.status]
      else
        result = [false, '未报名']
      end
    else
      result=[false, '参数不完整']
    end
    render json: result
  end

  def search_team
    event_id = params[:ed]
    team_name = params[:team_name]
    if event_id.present? && team_name.present?
      @teams = Team.find_by_sql("select a.id,a.name,a.teacher,up.username as leader, up.school as school,count(tu.team_id) as players,events.team_max_num as max_num from teams a inner join events on events.id=a.event_id inner join user_profiles up on a.user_id = up.user_id inner join team_user_ships tu on a.id = tu.team_id where a.event_id =#{event_id} and a.name like '%#{team_name}%' GROUP BY a.id")
      render json: [true, @teams]
    else
      render json: [false, ['参数不完整']]
    end
  end

  def update_apply_info
    username = params[:username]
    gender = params[:gender].to_i
    grade = params[:grade]
    district = params[:district].to_i
    school = params[:school].to_i
    if /\A[\u4e00-\u9fa5]{2,4}\Z/.match(username)==nil
      status = false
      message= '姓名为2-4位中文'
    elsif username.present? && school !=0 && grade.present? && gender !=0 && district != 0
      user = UserProfile.find_by(user_id: current_user.id)
      if user.present?
        user.username = username
        user.gender = gender
        user.school = school
        user.grade = grade
        user.district = district
        if user.save
          status = true
          message = '个人信息确认成功'
        else
          status = false
          message = '个人信息更新失败'
        end
      else
        up = UserProfile.create!(user_id: current_user.id, username: username, gender: gender, school: school, grade: grade, district: district)
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
      user = User.where(email: params[:invited_email]).select(:id).take
      if user.present?
        is_player = TeamUserShip.where(team_id: params[:td], user_id: user.id).take
        if is_player
          render json: [false, '该用户已是该队队员或已被邀请']
        else
          TeamUserShip.create!(team_id: params[:td], user_id: user.id, event_id: params[:ed], status: false)
          notify = Notification.create!(user_id: user.id, message_type: '队长邀请队员', content: current_user.user_profile.username.to_s+'邀请你参加'+params[:event_name]+'比赛项目,队伍为:'+params[:team_name], team_id: params[:td])

          if notify.save
            render json: [true, '已向该验证用户发送邀请消息']
          end
        end
        ## 未验证
      else
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

  def apply_join_team
    if params[:leader].present? && params[:td].present? && params[:ed].present? && current_user.validate_status=='1'
      if TeamUserShip.where(team_id: params[:td], event_id: params[:ed], user_id: current_user.id).exists?
        result = [false, '您已经申请过或已是该队队员']
      else
        t_u = TeamUserShip.create!(event_id: params[:ed], team_id: params[:td], user_id: current_user.id, status: false)
        if t_u.save
          info = Team.joins(:event).where(id: params[:td]).where("teams.event_id=events.id").select("teams.name as team_name", "events.name as event_name").first
          notify = Notification.create!(user_id: params[:leader], content: current_user.user_profile.username+'申请加入您在比赛项目－'+ info.event_name.to_s + '中创建的队伍－'+info.team_name, t_u_id: t_u.id, message_type: '申请加入队伍')
          if notify.save
            result = [true, '申请成功，已向队长发出消息，等待队长同意']
          else
            t_u.delete
            result = [false, '申请失败']
          end
        else
          result = [false, '申请失败']
        end
      end
    else
      result = [false, '个人信息或参数不完整']
    end
    render json: result
  end

  def leader_agree_apply
    if params[:tud].present?
      t_u = TeamUserShip.includes(:team).find(params[:tud])
      if t_u.team.user_id != current_user.id
        flash[:error] = '非法请求'
      else
        info = Team.joins(:event).where(id: t_u.team_id).where("teams.event_id=events.id").select("teams.name as team_name", "events.name as event_name").first
        if params[:reject].present? && params[:reject]=='1'
          Notification.create!(user_id: t_u.user_id, content: info.event_name+'比赛项目中'+info.team_name+'的队长拒绝了你的申请，您未能加入该队', message_type: '拒绝申请')
          if t_u.delete
            flash[:success] = '拒绝成功'
            redirect_to "/user/notify?id=#{params[:nd]}"
          else
            flash[:error] = '拒绝失败'
          end
        else
          t_u.status = true
          if t_u.save
            flash[:success] = '接受成功'
            Notification.create!(user_id: t_u.user_id, content: info.event_name+'比赛项目中'+info.team_name+'的队长同意了你的申请，您已成功加入了该队', message_type: '同意申请')
            redirect_to "/user/notify?id=#{params[:nd]}"
          else
            flash[:error] = '接受失败'
          end
        end
      end
    end
  end


  def delete_team
    team = Team.find(params[:id])
    if team.user_id == current_user.id
      team.destroy
      t_u = TeamUserShip.where(team_id: params[:id])
      if team.destroy && t_u.destroy_all
        result = [true, '解散队伍成功!']
      else
        result = [false, '解散队伍失败!']
      end
    else
      result = [false, '您不是该队队长，无法解散队伍!']
    end
    render json: result
  end

  def leader_delete_player
    t_u = TeamUserShip.where(user_id: params[:user_id], team_id: params[:team_id]).take
    t_u.destroy
    if t_u.destroy
      result = [true, '清退成功!']
    else
      result = [false, '清退失败!']
    end
    render json: result
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
