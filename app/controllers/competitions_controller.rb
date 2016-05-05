class CompetitionsController < ApplicationController
  before_action :require_user, except: [:index, :show, :invite]
  before_action :set_competition, only: [:show]
  layout 'invite', only: [:invite]

  def index
    @competitions = Competition.all.page(params[:page]).per(params[:per])
  end

  def show
  end

  def apply_event
    if require_email
      @competition = Competition.find(params[:cd])
      @events = Event.where(competition_id: params[:cd], is_father: false).select(:name, :id, :team_max_num)
      #   @teams = Team.includes(:team_user_ships).where(event_id: params[:eid])
      #   @already_apply = TeamUserShip.includes(:team).where(event_id: params[:eid], user_id: current_user.id).take
      #   if @already_apply.present?
      #     @team_players = TeamUserShip.where(team_id: @already_apply.team_id).count
      #   end
    else
      redirect_to "/competitions/#{params[:cd]}", notice: '继续操作前请验证邮箱'
    end
  end

  def already_apply
    if params[:ed].present?
      event = Event.find(params[:ed])
      if event.present?
        a_p = TeamUserShip.where(event_id: params[:ed], user_id: current_user.id).take
        if a_p.present?
          team_players = Team.find_by_sql("select t.user_id as id,a.team_id,u_p.username,u_p.grade as grade,u_p.user_id as user_id,u_p.gender as gender, a.status,t.name as name,s.name as school from team_user_ships a INNER JOIN teams t on t.id = a.team_id inner join user_profiles u_p on u_p.user_id = a.user_id inner join schools s on s.id = u_p.school where a.team_id = #{a_p.team_id}")
          result =[true, team_players, event.group]
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
    bj = params[:bj]
    student_code = params[:student_code]
    district = params[:district].to_i
    school = params[:school1].to_i
    if params[:school2].present? && params[:school2].to_i !=0
      sk_station = params[:school2].to_i
    else
      sk_station = nil
    end

    join = params[:join]
    ed = params[:ed].to_i
    td = params[:td].to_i
    if /\A[\u4e00-\u9fa5]{2,4}\Z/.match(username)==nil
      status = false
      message= '姓名为2-4位中文'
    elsif username.present? && school !=0 && grade.present? && gender !=0 && district != 0 && student_code.present? && bj.present?
      user = UserProfile.find_by(user_id: current_user.id)
      if user.present?
        user.username = username
        user.gender = gender
        user.school = school
        user.sk_station = sk_station
        user.grade = grade
        user.bj = bj
        user.student_code = student_code
        user.district = district
        if user.save
          s = true
          m = '个人信息确认成功'
        else
          s = false
          m = '个人信息更新失败'
        end
      else
        up = UserProfile.create!(user_id: current_user.id, username: username, gender: gender, school: school, grade: grade, bj: bj, student_code: student_code, district: district)
        if up.save
          s = true
          m = '个人信息添加成功'
        else
          s = false
          m = '个人信息添加失败'
        end
      end

      if s && join
        if td !=0 && ed !=0
          result=self.apply_join_team(td, ed)
          status = result[0]
          message = result[1]
        else
          status = false
          message = '队伍和项目相关信息不完整'
        end
      else
        status = s
        message= m
      end
    else
      status = false
      message = '个人信息输入不完整'
    end
    render json: [status, message]
  end

  def apply_join_team(td, ed)
    if td.present? && ed.present? && current_user.validate_status=='1'
      if TeamUserShip.where(team_id: td, event_id: ed, user_id: current_user.id).exists?
        [false, '您已经申请过或已是该队队员']
      else
        t_u = TeamUserShip.create!(event_id: ed, team_id: td, user_id: current_user.id, status: false)
        if t_u.save
          info = Team.joins(:event).where(id: td).where("teams.event_id=events.id").select("teams.name as team_name", "events.name as event_name").first
          notify = Notification.create!(user_id: t_u.user_id, content: current_user.user_profile.username+'申请加入您在比赛项目－'+ info.event_name.to_s + '中创建的队伍－'+info.team_name, t_u_id: t_u.id, message_type: '申请加入队伍')
          if notify.save
            [true, '申请成功，已向队长发出消息，等待队长同意']
          else
            t_u.delete
            [false, '申请失败']
          end
        else
          [false, '申请失败']
        end
      end
    else
      [false, '个人信息或参数不完整']
    end
  end

  def leader_create_team
    user_id = current_user.id
    team_name = params[:team_name]
    district_id = params[:team_district].to_i
    teacher = params[:team_teacher]
    ed = params[:team_event].to_i
    group = params[:group].to_i
    sd = params[:sd].to_i
    if params[:skd].present?
      skd = params[:skd].to_i
    else
      skd=nil
    end
    if params[:teacher_mobile].present?
      teacher_mobile = params[:teacher_mobile]
    else
      teacher_mobile=nil
    end
    unless skd!=sd
      render json: [false, '两所学校不能一样']
      return false
    end
    if team_name.present? && district_id !=0 && ed !=0 && sd !=0 && teacher.present? && group != 0
      already_apply = TeamUserShip.where(user_id: user_id, event_id: ed).exists?
      has_team_name = Team.where(event_id: ed, name: team_name).take
      if already_apply
        result = [false, '该比赛您已经报名，请不要再次报名!']
      elsif has_team_name.present?
        result = [false, '很抱歉，该比赛中队伍['+has_team_name.name+']已存在，请更改队伍名称!']
      else
        team = Team.create!(name: team_name, group: group, district_id: district_id, user_id: user_id, teacher: teacher, teacher_mobile: teacher_mobile, event_id: ed, school_id: sd, sk_station: skd)
        if team.save
          team_user_ship = TeamUserShip.create!(team_id: team.id, user_id: team.user_id, event_id: ed)
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
    else
      result=[false, '参数不完整']
    end
    render json: result
  end

  def search_user
    if request.method == 'GET' && params[:invited_name].present? && params[:invited_name].length>1
      users = User.joins(:user_profile).joins('inner join schools s on s.id = user_profiles.school').where(['user_profiles.username like ?', "#{params[:invited_name]}%"]).where('email is not NULL').where(validate_status: '1').select(:email, 'user_profiles.username', 's.name', 'user_profiles.gender', 'user_profiles.grade', 'user_profiles.bj')
      result = [true, users]
    else
      result = [false, '请至少输入名字的前两个字']
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
          puts '123qwe'
          invite_action = Invite.create!(email: params[:invited_email], code: code, invite_type: 'LEADER_INVITE', user_id: current_user.id, team_id: params[:td])
          if invite_action.save
            puts '1qas'
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

  def leader_deal_cancel_team
    if params[:tud].present?
      t_u = TeamUserShip.includes(:team).find(params[:tud])
      if t_u.present? && t_u.team.user_id != current_user.id
        flash[:error] = '非法请求'
      else
        info = Team.joins(:event).where(id: t_u.team_id).where("teams.event_id=events.id").select("teams.name as team_name", "events.name as event_name").first
        if params[:reject].present? && params[:reject]=='1'
          notify = Notification.create!(user_id: t_u.user_id, content: info.event_name+'比赛项目中'+info.team_name+'的队长拒绝了你的退出申请，您未能退出该队', message_type: '拒绝申请')
          if notify.save
            flash[:success] = '拒绝成功,结果已告知该队员'
            redirect_to "/user/notify?id=#{params[:nd]}"
          else
            flash[:error] = '拒绝成功,结果未能告知该用户'
          end
        else
          if t_u.delete
            Notification.create!(user_id: t_u.user_id, content: info.event_name+'比赛项目中'+info.team_name+'的队长同意了你的申请，您已成功退出该队', message_type: '同意申请')
            flash[:success] = '同意退出成功'
            redirect_to "/user/notify?id=#{params[:nd]}"
          else
            flash[:error] = '同意申请失败'
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

  def player_cancel_join
    td = params[:td].to_i
    username = params[:username]
    if request.method == 'POST' && td!=0 && params[:username].present?
      team = TeamUserShip.joins(:team).where(team_id: params[:td], user_id: current_user.id).select(:id, :team_id, :user_id, 'teams.name', 'teams.user_id as leader')
      if team.present?
        notify = Notification.create(user_id: team.leader, content: username+'申请退出队伍：'+team.name, t_u_id: team.id, team_id: team.team_id, message_type: '申请退出队伍', reply_to: team.user_id)
        if notify.save
          result = [true, '已向队长发出申请，队长审核后将通过消息通知您']
        else
          result = [false, '申请失败']
        end
      else
        result = [false, '队伍不存在']
      end
    else
      result = [false, '参数不完整']
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
        @is_invite = Invite.joins(:team).joins('inner join user_profiles u_p on u_p.user_id=invites.user_id').where(email: invited_email, code: invited_code).select("teams.name as team_name", "u_p.username as leader", :email, :code).take
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
      school = params[:invite_player][:school].to_i
      gender = params[:invite_player][:gender].to_i
      student_code = params[:invite_player][:student_code]
      email = params[:invite_player][:email]
      code = params[:invite_player][:code]
      @add_info = InvitePlayer.new(email: email, code: code, nickname: nickname, username: username, gender: gender, student_code: student_code, grade: grade, school: school, password: params[:invite_player][:password])
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
