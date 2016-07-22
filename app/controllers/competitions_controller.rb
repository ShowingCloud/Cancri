class CompetitionsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :invite, :events]
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

  def events
    @events = Event.left_joins(:competition).where(competition_id: params[:id], is_father: 0).select('events.*', 'competitions.name as comp_name', 'competitions.apply_end_time as end_apply_time').page(params[:page]).per(params[:per])
  end

  def apply_event
    if require_mobile
      @event = Event.joins(:competition).where(id: params[:ed]).select('events.*', 'competitions.name as comp_name', 'competitions.apply_end_time as end_apply_time').take
      if @event.present?
        a_p = TeamUserShip.where(event_id: params[:ed], user_id: current_user.id).take
        if a_p.present?
          @has_apply = true
          @team_players = Team.find_by_sql("select t.user_id as leader_user_id,a.team_id,u_p.username,u_p.bj,t.identifier,t.teacher,t.teacher_mobile,u_p.grade as grade,u_p.user_id as user_id,u_p.gender as gender, a.status,t.status as team_status,t.name as team_name,s.name as school_name from team_user_ships a INNER JOIN teams t on t.id = a.team_id left join user_profiles u_p on u_p.user_id = a.user_id left join schools s on s.id = u_p.school_id where a.team_id = #{a_p.team_id}")
        else
          @has_apply = false
        end
      end
      user_info = UserProfile.left_joins(:school, :district).where(user_id: current_user.id).select('user_profiles.*', 'schools.name as school_name', 'districts.name as district_name').take; false
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
    district_id = params[:district]
    school_id = params[:school]
    grade = params[:grade]
    birthday = params[:birthday]
    student_code = params[:student_code]
    identity_card = params[:identity_card]

    td = params[:td]


    if username.present? && school_id.to_i !=0 && grade.to_i !=0 && gender.present? && district_id.to_i != 0 && student_code.present? && birthday.present? && td.to_i !=0
      if has_teacher_role
        result = [false, '不规范请求']
      else
        user_profile = current_user.user_profile ||= current_user.build_user_profile
        if user_profile.update_attributes(username: username, gender: gender, school_id: school_id, grade: grade, district_id: district_id, student_code: student_code, birthday: birthday, identity_card: identity_card)
          event = Team.joins(:event).joins('left join competitions c on events.competition_id = c.id').where('teams.id=?', td).select('c.apply_end_time', 'events.team_max_num', :players, :identifier, 'events.id as event_id', 'teams.user_id', 'events.name as event_name').take
          if event.present? && (event.apply_end_time > Time.now) && (event.team_max_num > 1) && (event.team_max_num > event.players)
            already_apply = TeamUserShip.where(user_id: user_id, event_id: event.event_id).exists?
            if already_apply.present?
              result = [false, '该比赛您已报名或等待队长审核']
            else
              t_u = TeamUserShip.create(team_id: td, user_id: user_id, event_id: event.event_id, district_id: district_id, school_id: school_id, grade: grade, status: true)
              if t_u.save
                notify = Notification.create(user_id: event.user_id, content: username+' 申请加入您在比赛项目－'+ event.event_name.to_s + '中创建的队伍－'+ event.identifier, t_u_id: t_u.id, team_id: td, message_type: 2, reply_to: user_id)
                if notify.save
                  result = [true, '申请成功,等待队长同意,结果将会通过消息推送告知您!']
                else
                  t_u.destroy
                  result = [false, '申请失败!']
                end
              else
                result = [false, '申请失败!']
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
    render json: result
  end

  def leader_create_team

    user_id = current_user.id
    username = params[:username]
    gender = params[:gender]
    district_id = params[:district]
    school_id = params[:school]
    grade = params[:grade]
    birthday = params[:birthday]
    student_code = params[:student_code]
    identity_card = params[:identity_card]

    group = params[:team_group]
    teacher = params[:teacher_name]
    teacher_mobile = params[:teacher_mobile]
    ed = params[:team_event]


    if /\A[\u4e00-\u9fa5]{2,10}\Z/.match(username)== nil
      result = [false, ' 姓名为2-10 位中文 ']
    elsif ([grade.to_i] & [10, 11, 12]).present? && /^[1-9]\d{5}[1-9]\d{3}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{3}([0-9]|X)$/.match(identity_card) == nil
      result = [false, ' 高中生请正确填写18位身份证号 ']
    elsif school_id.to_i !=0 && grade.to_i !=0 && gender.present? && district_id.to_i != 0 && student_code.present? && birthday.present? && teacher.present? && teacher_mobile.present?
      if has_teacher_role
        result = [false, ' 不规范请求 ']
      else
        user = current_user.user_profile ||= current_user.build_user_profile
        if user.update_attributes(username: username, gender: gender, school_id: school_id, grade: grade, district_id: district_id, student_code: student_code, birthday: birthday, identity_card: identity_card)
          event = Event.joins(:competition).where(id: ed).select(' competitions.apply_end_time ').take
          if event.present? && event.apply_end_time > Time.now
            already_apply = TeamUserShip.where(user_id: user_id, event_id: ed, status: true).exists?
            if already_apply
              result = [false, ' 该比赛您已经报名 ， 请不要再次报名! ']
            else
              team = Team.create(group: group, district_id: district_id, user_id: user_id, teacher: teacher, teacher_mobile: teacher_mobile, event_id: ed, school_id: school_id)
              if team.save
                if TeamUserShip.create(team_id: team.id, user_id: team.user_id, event_id: ed, district_id: district_id, school_id: school_id, grade: grade, status: true).save
                  result = [true, ' 队伍创建成功! ']
                else
                  team.delete
                  result = [false, ' 队伍创建失败 ']
                end
              else
                result = [false, team.errors.full_messages.first]
              end
            end
          else
            result = [false, ' 不规范请求或已过报名时间! ']
          end
        else
          result = [false, ' 个人信息保存失败, 请注意数据规范 ']
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
      @team = TeamUserShip.left_joins(:team, :school, :event).joins(' left join user_profiles up on up.user_id = team_user_ships.user_id ').select(' schools.name as school_name ', ' events.team_max_num ', ' teams.identifier ', ' teams.players ', ' teams.teacher ', ' teams.teacher_mobile ', ' teams.user_id as leader_id ', ' team_user_ships.user_id ', ' up.username ', ' team_user_ships.grade ').where(' teams.identifier = ?', team_identify).where('teams.event_id=?', event_id)
      render json: [true, @team]
    else
      render json: [false, ['参数不完整']]
    end
  end

  def search_user
    if request.method == 'GET' && params[:invited_name].present? && params[:invited_name].length>1
      users = UserProfile.joins(:user, :school).where('user_profiles.username is not NULL').where(['user_profiles.username like ?', "#{params[:invited_name]}%"]).select(:user_id, :nickname, 'user_profiles.username', 'schools.name as school_name', 'user_profiles.gender', 'user_profiles.grade')
      result = [true, users]
    else
      result = [false, '请至少输入名字的前两个字']
    end
    render json: result
  end


  protected

  def set_competition
    @competition = Competition.find(params[:id])
  end
end
