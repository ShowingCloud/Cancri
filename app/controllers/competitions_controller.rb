class CompetitionsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :invite, :events, :apply_process]
  before_action :set_competition, only: [:show]

  def index
    host_year = params[:host_year]
    competitions = Competition.where.not(status: 0); false
    if host_year.present?
      competitions = competitions.where(host_year: host_year)
    end

    if cookies[:area] == '1'
      competitions = competitions.where(district_id: 9)
    end
    @competitions = competitions.select(:id, :name, :cover).order('id desc').page(params[:page]).per(params[:per])
  end

  def show
  end

  def apply_process

  end

  def events
    @competition = Competition.find(params[:id])
    if current_user
      current_user_id = current_user.id
      events = Event.joins("left join team_user_ships t_u on t_u.event_id = events.id and t_u.user_id = #{current_user_id}").joins('left join teams t on t.id = t_u.team_id').where(competition_id: @competition.id, is_father: 0).select(:id, :name, :group, :team_max_num, 't.user_id as leader_id', 't.status as team_status', 't.identifier', 't_u.user_id as player_id', 't_u.team_id', 't_u.status as apply_status')
      already_events = events.select { |event| event.apply_status != nil }
      user_info = UserProfile.left_joins(:school, :district).where(user_id: current_user_id).select('user_profiles.*', 'schools.name as school_name', 'districts.name as district_name').take
      @user_info = user_info || current_user.build_user_profile
    else
      events = Event.where(competition_id: @competition.id, is_father: 0).select(:id, :name, :group, :team_max_num)
      already_events = []
    end
    one_events = events.select { |event| event.team_max_num == 1 } - already_events
    multiple_events = events - one_events - already_events
    @events = {already: already_events, one: one_events, multiple: multiple_events}
  end

  def apply_event
    event_id = params[:ed]
    if require_mobile
      current_user_id = current_user.id
      @event = Event.joins(:competition).where(id: event_id).select('events.*', 'competitions.name as comp_name', 'competitions.apply_end_time as end_apply_time').take
      if @event.present?
        a_p = TeamUserShip.where(event_id: event_id, user_id: current_user_id).take
        if a_p.present?
          if a_p.status
            @has_apply = [true, true]
          else
            @has_apply = [true, false]
          end
          @team_players = Team.find_by_sql("select t.id as team_id, t.user_id as leader_user_id,t.players,a.team_id,u_p.username,u_p.bj,t.identifier,t.teacher,t.teacher_mobile,u.nickname,u_p.grade as grade,u_p.user_id as user_id,u_p.gender as gender, a.status as player_status,t.status as team_status,s.name as school_name from team_user_ships a INNER JOIN teams t on t.id = a.team_id left join user_profiles u_p on u_p.user_id = a.user_id left join users u on u.id = u_p.user_id left join schools s on s.id = a.school_id where a.team_id = #{a_p.team_id}")
        else
          @has_apply = [false, false]
        end
      end
      user_info = UserProfile.left_joins(:school, :district).where(user_id: current_user_id).select('user_profiles.*', 'schools.name as school_name', 'districts.name as district_name').take; false
      @user_info = user_info ||= current_user.build_user_profile
    else
      session[:redirect_to] = request.headers[:Referer]
      redirect_to user_mobile_path, notice: '继续操作前请添加手机信息'
    end
  end


  def apply_join_team
    user_id = current_user.id
    username = params[:username]
    gender = params[:gender]
    school_id = params[:school_id]
    grade = params[:grade]
    bj = params[:bj]
    birthday = params[:birthday]
    student_code = params[:student_code]
    identity_card = params[:identity_card]
    td = params[:td]


    if username.present? && school_id.to_i !=0 && grade.to_i !=0 && bj.present? && gender.present? && student_code.present? && birthday.present? && td.to_i !=0
      if has_teacher_role
        result = [false, '您是教师，不能报名比赛!']
      else
        user_profile = current_user.user_profile ||= current_user.build_user_profile
        if user_profile.update_attributes(username: username, gender: gender, school_id: school_id, grade: grade, student_code: student_code, birthday: birthday, identity_card: identity_card)
          event = Team.joins(:event).joins('left join competitions c on events.competition_id = c.id').where('teams.id=?', td).select('c.apply_end_time', 'events.team_max_num', :players, :identifier, 'events.id as event_id', 'teams.user_id', 'teams.status as team_status', 'events.name as event_name').take
          if event.present? && (event.apply_end_time > Time.zone.now) && (event.team_max_num > 1) && (event.team_max_num > event.players) && (event.team_status == 0)
            already_apply = TeamUserShip.where(user_id: user_id, event_id: event.event_id).exists?
            if already_apply.present?
              result = [false, '该比赛您已报名或等待队长审核']
            else
              begin
                Notification.transaction do
                  t_u = TeamUserShip.create!(team_id: td, user_id: user_id, event_id: event.event_id, school_id: school_id, grade: grade, status: 0)
                  Notification.create!(user_id: event.user_id, content: username+' 申请加入您在比赛项目－'+ event.event_name.to_s + '中创建的队伍－'+ event.identifier, t_u_id: t_u.id, team_id: td, message_type: 2, reply_to: user_id)
                end
                result = [true, '申请成功,等待队长同意,结果将会通过消息推送告知您!']
              rescue Exception => ex
                result = [false, ex.message]
              end
            end
          else
            result = [false, '不规范请求或已过报名时间!']
          end
        else
          result = [false, user_profile.errors.full_messages.first]
        end
      end
    else
      result = [false, '信息输入不完整']
    end
    render json: {status: result[0], message: result[1]}
  end


  def leader_batch_apply
    user_id = current_user.id
    username = params[:username]
    gender = params[:gender]
    school_id = params[:school_id]
    sk_station = params[:sk_station]
    grade = params[:grade]
    bj = params[:bj]
    birthday = params[:birthday]
    student_code = params[:student_code]
    identity_card = params[:identity_card]
    group = params[:group]
    teacher = params[:teacher]
    eds = params[:eds]

    if eds.present? && eds.is_a?(Array) && eds.length < 6 && username.present? && school_id.to_i !=0 && grade.to_i !=0 && gender.present? && student_code.present? && birthday.present? && teacher.present? && group.present?
      if has_teacher_role
        result = [false, '您是老师,不能报名比赛!']
      else
        if current_user.mobile.present?
          events = Event.joins(:competition).where(id: eds).select(:id, :name, :group, 'competitions.apply_end_time')
          if events.present? && events.length == eds.length
            if events[0].apply_end_time > Time.zone.now
              already_apply = TeamUserShip.where(user_id: user_id, event_id: eds).exists?
              if already_apply
                result = [false, '您提交的项目中部分您已报名，无需再次报名']
              else
                user_profile = current_user.user_profile ||= current_user.build_user_profile
                if user_profile.update_attributes(username: username, gender: gender, school_id: school_id, grade: grade, bj: bj, student_code: student_code, birthday: birthday, identity_card: identity_card)
                  result_status = true
                  result = []
                  success_teams = []
                  each_index = 0
                  events.each_with_index do |event, index|
                    each_index = index
                    if event.group.include?(group)
                      if result_status
                        begin
                          TeamUserShip.transaction do
                            team = Team.create!(group: group, user_id: user_id, teacher: teacher, event_id: event.id, school_id: school_id, sk_station: sk_station)
                            team.team_user_ships.create!(team_id: team.id, user_id: user_id, event_id: event.id, school_id: school_id, grade: grade, status: true)
                            result << "#{event.name}报名成功!"
                            success_teams << {event_name: event.name, team_id: team.id, identifier: team.identifier, event_id: event.id}
                          end
                        rescue Exception => ex
                          result_status = false
                          result << ex.message
                        end
                      else
                        break
                      end
                    else
                      result << [false, "#{event.name}不包含您所报名的组别！"]
                      result_status = false
                      break
                    end
                  end
                  if result_status
                    result = [true, '提交成功', success_teams]
                  else
                    if each_index > 0
                      result = [true, (result[0..-2]+['剩余项目报名失败']).join(','), success_teams]
                    else
                      result = [false, result[0]]
                    end
                  end
                else
                  result = [false, user_profile.errors.full_messages.first]
                end
              end
            else
              result = [false, '该比赛已过报名时间']
            end
          else
            result = [false, '项目参数不规范']
          end
        else
          result = [false, '请先添加手机号!']
        end
      end
    else
      result = [false, '信息输入不完整或不规范']
    end
    render json: {status: result[0], message: result[1], success_teams: result[2]}
  end


  ## old
  def leader_create_team

    user_id = current_user.id
    username = params[:username]
    gender = params[:gender]
    school_id = params[:school]
    grade = params[:grade]
    birthday = params[:birthday]
    student_code = params[:student_code]
    identity_card = params[:identity_card]

    group = params[:team_group]
    teacher = params[:teacher_name]
    teacher_mobile = params[:teacher_mobile]
    ed = params[:team_event]


    if username.present? && school_id.to_i !=0 && grade.to_i !=0 && gender.present? && student_code.present? && birthday.present? && teacher.present? && group.present?
      if has_teacher_role
        result = [false, '您是老师,不能报名比赛']
      else
        user = current_user.user_profile ||= current_user.build_user_profile
        if user.update_attributes(username: username, gender: gender, school_id: school_id, grade: grade, student_code: student_code, birthday: birthday, identity_card: identity_card)
          event = Event.joins(:competition).where(id: ed).select(' competitions.apply_end_time ').take
          if event.present? && event.apply_end_time > Time.zone.now
            already_apply = TeamUserShip.where(user_id: user_id, event_id: ed, status: true).exists?
            if already_apply
              result = [false, ' 该比赛您已经报名 ， 请不要再次报名! ']
            else
              begin
                TeamUserShip.transaction do
                  team = Team.create!(group: group, user_id: user_id, teacher: teacher, teacher_mobile: teacher_mobile, event_id: ed, school_id: school_id)
                  TeamUserShip.create!(team_id: team.id, user_id: team.user_id, event_id: ed, school_id: school_id, grade: grade, status: true)
                end
                result = [true, '队伍创建成功!']
              rescue Exception => ex
                result = [false, ex.message]
              end
            end
          else
            result = [false, ' 不规范请求或已过报名时间! ']
          end
        else
          result = [false, user.errors.full_messages.first]
        end
      end
    else
      result = [false, ' 信息输入不完整 ']
    end
    render json: result
  end

  def search_team
    event_id = params[:ed]
    team_identify = params[:team]
    if event_id.present? && team_identify.present?
      team = Team.joins(:event).joins('left join schools on teams.school_id = schools.id').joins('left join user_profiles up on up.user_id = teams.user_id').where(event_id: event_id, identifier: team_identify).select(:id, :status, :identifier, :players, :teacher, :teacher_mobile, 'events.team_max_num', 'schools.name as school_name', 'up.username')
      result = [true, team]
    else
      result = [false, '参数不完整']
    end
    render json: result
  end

  def search_user
    invited_name = params[:invited_name]
    if request.method == 'GET' && invited_name.present? && invited_name.length>1
      users = UserProfile.left_joins(:user, :school).where(['user_profiles.username like ?', "#{invited_name}%"]).where('school_id is not NULL').select(:user_id, :nickname, 'user_profiles.username', 'schools.name as school_name', 'user_profiles.gender', 'user_profiles.grade', 'user_profiles.bj')
      result = [true, users]
    else
      result = [false, '请至少输入名字的前两个字']
    end
    render json: result
  end

  def leader_invite_player
    ud = params[:ud]
    td = params[:td]
    if request.method == 'POST' && ud.present? && td.present?
      event_info = Event.joins(:competition, :teams).where('teams.id=?', td.to_i).select(:id, :name, :team_max_num, 'competitions.apply_end_time', 'teams.players', 'teams.user_id', 'teams.identifier').take
      user_info = User.left_joins(:user_profile).where(id: ud).select(:id, :nickname, 'user_profiles.username').take
      if event_info.present? && (event_info.apply_end_time > Time.now) && (event_info.team_max_num > event_info.players) && (current_user.id == event_info.user_id) && user_info.present?
        if check_teacher_role(ud)
          result = [false, '不能邀请老师']
        else
          if TeamUserShip.where(user_id: ud, event_id: event_info.id).exists?
            result = [false, '该户已报名此项目或已被您或其他人邀请参加']
          else
            t_u = TeamUserShip.create(team_id: td, user_id: ud, event_id: event_info.id, status: 2, school_id: 0)
            if t_u.save
              result= [true, '邀请成功,等待该队员同意', user_info.nickname, user_info.username]
              Notification.create(user_id: ud, message_type: 1, content: current_user.user_profile.try(:username)+'邀请你参加['+event_info.name+']比赛项目,队伍为:'+event_info.identifier, t_u_id: t_u.id, team_id: td, reply_to: current_user.id)
            else
              result= [false, '邀请失败']
            end
          end
        end
      else
        result= [false, '不规范请求']
      end
    else
      result = [false, '信息不完整']
    end
    render json: result
  end


  def leader_delete_team
    td = params[:td]
    if td.present?
      team_info = Event.joins(:teams, :competition).where('teams.id=?', td).select(:name, :team_max_num, 'teams.user_id', 'teams.status', 'teams.players', 'competitions.apply_end_time').take
      if team_info.present? && (team_info.status ==0) && (team_info.user_id == current_user.id) && (team_info.apply_end_time > Time.now)
        if Team.find(td).destroy
          result = [true, '解散成功']
          if (team_info.team_max_num > 1) && (team_info.players>1)
            players = TeamUserShip.where(team_id: td).pluck(:id); false
            players.drop(current_user.id).each do |u|
              Notification.create(user_id: u, message_type: 0, content: '在比赛项目--'+team_info.name+'中,您参加的队伍已被队长解散')
            end
          end
        else
          result = [false, '解散失败']
        end
      else
        result = [false, '不规范请求或报名时间已截止']
      end
    else
      result = [false, '参数不完整']
    end
    render json: result
  end

  def leader_delete_player
    td = params[:td]
    ud = params[:ud]
    current_user_id = current_user.id
    if ud == current_user_id.to_s
      result = [false, '队长不能剔除自己']
    else
      team_info = Event.joins(:teams, :competition).where('teams.id=?', td).select(:name, 'teams.user_id', 'teams.status', 'competitions.apply_end_time').take
      if team_info.present? && (team_info.status ==0) && (team_info.user_id == current_user_id) && (team_info.apply_end_time > Time.now)
        t_u = TeamUserShip.where(user_id: ud, team_id: td).take
        if t_u.present? && t_u.destroy
          result = [true, '清退成功!']
          Notification.create(user_id: team_info.user_id, message_type: 0, content: '在比赛项目:'+team_info.name+'中,您被队长移出队伍')
        else
          result = [false, '清退失败!']
        end
      else
        result = [false, '不规范请求或报名时间已截止']
      end
    end
    render json: result
  end

  def player_agree_leader_invite
    username = params[:username]
    gender = params[:gender]
    district_id = params[:district]
    school_id = params[:school_id]
    grade = params[:grade]
    birthday = params[:birthday]
    student_code = params[:student_code]
    identity_card = params[:identity_card]
    td = params[:td]

    if username.present? && school_id.to_i !=0 && grade.to_i !=0 && gender.present? && district_id.to_i != 0 && student_code.present? && birthday.present?
      user_profile = current_user.user_profile ||= current_user.build_user_profile
      if user_profile.update_attributes(username: username, gender: gender, school_id: school_id, grade: grade, district_id: district_id, student_code: student_code, birthday: birthday, identity_card: identity_card)
        event = Event.joins(:teams, :competition).where('teams.id=?', td).select(:id,:name, 'competitions.apply_end_time', 'teams.user_id as leader_user_id', 'teams.status as team_status', 'teams.identifier').take
        if event.present? && event.apply_end_time > Time.now && event.team_status==0
          t_u = TeamUserShip.where(user_id: current_user.id, event_id: event.id).take
          if t_u.present?
            if t_u.status == 1
              result = [false, '该比赛您已经报名，请不要再次报名!']
            else
              if t_u.update_attributes(status: 1, school_id: school_id, district_id: district_id, grade: grade)
                result = [true, '操作成功,您已成为该队队员']
                Notification.create(user_id: event.leader_user_id, message_type: 0, content: username+'同意了您的邀请,加入了您在比赛项目:'+event.name+'中创建的队伍--'+event.identifier)
              else
                result= [false, '加入失败']
              end
            end
          else
            result = [false, '不规范请求!']
          end
        else
          result = [false, ' 不规范请求或已过报名时间! ']
        end
      else
        result = [false, user_profile.errors.full_messages.first]
      end
    else
      result = [false, '信息不完整']
    end
    render json: result
  end

  def leader_deal_player_apply
    t_u_id = params[:tud]
    notification_id = params[:nd]
    reject = params[:reject] # option
    if t_u_id.present? && (request.format.json? || (request.format.html? && notification_id.present?))
      t_u = TeamUserShip.where(id: t_u_id).first
      if t_u.present?
        team_info = Event.joins(:competition).left_joins(:teams).where('teams.id=?', t_u.team_id).select(:name, 'competitions.apply_end_time', 'teams.user_id as leader_user_id', 'teams.status as team_status', 'teams.identifier').take
        if team_info.present? && (team_info.apply_end_time > Time.now) && (team_info.team_status ==0) && (t_u.status == 0) && (team_info.leader_user_id == current_user.id)
          if reject.present? && reject=='1'
            Notification.create(user_id: t_u.user_id, content: team_info.name+'比赛项目中队伍'+team_info.identifier+'的队长拒绝了你的申请，您未能加入该队', message_type: 0)
            if t_u.destroy
              result = [true, '拒绝成功']
            else
              result = [false, '拒绝失败']
            end
          else
            t_u.status = 1
            if t_u.save
              result = [true, '接受成功']
              Notification.create(user_id: t_u.user_id, content: team_info.name+'比赛项目中'+team_info.identifier+'的队长同意了你的申请，您已成功加入了该队', message_type: 0)
            else
              result = [false, '接受失败']
            end
          end
        else
          result = [false, '不规范请求']
        end
      else
        result = [false, '不规范请求']
      end
    else
      result = [false, '参数不规范']
    end
    respond_to do |format|
      format.html { redirect_to "/user/notify?id=#{notification_id}", notice: result[1] }
      format.json { render json: result }
    end
  end

  def school_refuse_teams
    com_id = params[:comd]
    team_ids = params[:tds]
    if com_id.present? && team_ids.present? && team_ids.is_a?(Array)
      competition = Competition.where(id: com_id, status: 1).select(:school_audit_time).take
      if competition.present? && competition.school_audit_time > Time.now
        team_ids = team_ids.map { |t| t.to_i }
        teacher_info = UserRole.joins('left join user_profiles u_p on user_roles.user_id = u_p.user_id').where(role_id: 1, status: 1, user_id: current_user.id).select(:role_type, :school_id, :district_id).take
        if teacher_info.present? && teacher_info.role_type == 3 && teacher_info.school_id.present?
          all_team_ids = Team.joins(:event).where(school_id: teacher_info.school_id, status: [2, 3]).where('events.competition_id = ?', com_id).pluck(:id); false
          if (all_team_ids & team_ids).length == team_ids.length
            if Team.where(id: team_ids).update_all(status: -2) == team_ids.length
              result = [true, '拒绝成功']
            else
              result = [false, '有部分队伍拒绝失败']
            end
          else
            result = [false, '不规范操作']
          end
        else
          result = [false, '没有权限']
        end
      else
        result = [false, '不规范请求或已过学校审核时间']
      end
    else
      result = [false, '参数不规范']
    end
    render json: result
  end

  def district_refuse_teams
    com_id = params[:comd]
    team_ids = params[:tds]
    if team_ids.present? && team_ids.is_a?(Array) && com_id.present?
      competition = Competition.where(id: com_id, status: 1).select(:district_audit_time).take
      if competition.present? && competition.district_audit_time > Time.now
        team_ids = team_ids.map { |t| t.to_i }
        teacher_info = UserRole.joins('left join user_profiles u_p on user_roles.user_id = u_p.user_id').where(role_id: 1, status: 1, user_id: current_user.id).select(:role_type, :school_id, :district_id).take
        if teacher_info.present? && teacher_info.role_type == 2 && teacher_info.district_id.present?
          all_team_ids = Team.joins(:event).where(district_id: teacher_info.district_id, status: [2, 3]).where('events.competition_id = ?', com_id).pluck(:id); false
          if (all_team_ids & team_ids).length == team_ids.length
            if Team.where(id: team_ids).update_all(status: -3) == team_ids.length
              result = [true, '拒绝成功']
            else
              result = [false, '有部分队伍拒绝失败']
            end
          else
            result = [false, '不规范操作']
          end
        else
          result = [false, '没有权限']
        end
      else
        result = [false, '不规范请求或已过区县审核时间']
      end
    else
      result = [false, '参数不规范']
    end
    render json: result
  end


  def leader_submit_team
    team_id = params[:td]
    if team_id.present?
      team = Team.joins(:event).joins('left join competitions c on c.id = events.competition_id').where('teams.id=?', team_id).select('teams.*', 'c.apply_end_time', 'events.team_max_num').take
      if team.present? && (team.apply_end_time > Time.now) && (team.status ==0) && (team.user_id == current_user.id)
        if (team.team_max_num > 1) && (team.team_user_ships.pluck(:status) & [false]).count > 0
          result = [false, '有队员还未确认参加,不能提交']
        else
          if team.update_attributes(status: 2)
            result = [true, '提交成功,审核结果将会在消息中告知您']
          else
            result = [false, '提交失败']
          end
        end
      else
        result = [false, '不规范操作或已过报名时间']
      end
    else
      result = [false, '参数不完整']
    end
    render json: result
  end

  def school_submit_teams
    com_id = params[:comd]
    team_ids = params[:tds]
    if com_id.present? && team_ids.present? && team_ids.is_a?(Array)
      competition = Competition.where(id: com_id, status: 1).select(:school_audit_time).take
      if competition.present? && competition.school_audit_time > Time.now
        team_ids = team_ids.map { |t| t.to_i }
        teacher_info = UserRole.joins('left join user_profiles u_p on user_roles.user_id = u_p.user_id').where(role_id: 1, status: 1, user_id: current_user.id).select(:role_type, :school_id, :district_id).take
        if teacher_info.present? && teacher_info.role_type == 3 && teacher_info.school_id.present?
          all_team_ids = Team.joins(:event).where(school_id: teacher_info.school_id, status: [2, -2]).where('events.competition_id = ?', com_id).pluck(:id); false
          if (all_team_ids & team_ids).length == team_ids.length
            if Team.where(id: team_ids).update_all(status: 3) == team_ids.length
              result = [true, '提交成功']
            else
              result = [false, '有部分未提交成功']
            end
          else
            result = [false, '不规范操作']
          end
        else
          result = [false, '没有权限']
        end
      else
        result = [false, '不规范请求或已过学校审核提交时间']
      end
    else
      result = [false, '参数不规范']
    end
    render json: result
  end

  def district_submit_teams
    com_id = params[:comd]
    team_ids = params[:tds]
    if team_ids.present? && team_ids.is_a?(Array) && com_id.present?
      competition = Competition.where(id: com_id, status: 1).select(:district_audit_time).take
      if competition.present? && competition.district_audit_time > Time.now
        team_ids = team_ids.map { |t| t.to_i }
        teacher_info = UserRole.joins('left join user_profiles u_p on user_roles.user_id = u_p.user_id').where(role_id: 1, status: 1, user_id: current_user.id).select(:role_type, :school_id, :district_id).take
        if teacher_info.present? && teacher_info.role_type == 2 && teacher_info.district_id.present?
          all_team_ids = Team.joins(:event).where(district_id: teacher_info.district_id, status: [2, 3, -3]).where('events.competition_id = ?', com_id).pluck(:id); false
          if (all_team_ids & team_ids).length == team_ids.length
            if Team.where(id: team_ids).update_all(status: 1) == team_ids.length
              result = [true, '提交成功']
            else
              result = [false, '有部分未提交成功']
            end
          else
            result = [false, '不规范操作']
          end
        else
          result = [false, '没有权限']
        end
      else
        result = [false, '不规范请求或已过区县审核时间']
      end
    else
      result = [false, '参数不规范']
    end
    render json: result
  end


  protected

  def set_competition
    @competition = Competition.find(params[:id])
  end
end
