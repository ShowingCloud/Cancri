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

  def events
    @events = Event.left_joins(:competition).where(competition_id: params[:id], is_father: 0).select('events.*', 'competitions.name as comp_name', 'competitions.apply_end_time as end_apply_time').page(params[:page]).per(params[:per])
  end

  def apply_event
    if require_mobile
      @event = Event.joins(:competition).where(id: params[:ed]).select('events.*', 'competitions.name as comp_name', 'competitions.apply_end_time as end_apply_time').take
      if @event.present?
        a_p = TeamUserShip.where(event_id: params[:ed], user_id: current_user.id).take
        if a_p.present?
          @team_players = Team.find_by_sql("select t.user_id as id,a.team_id,u_p.username,u_p.bj,t.identifier,t.teacher,t.teacher_mobile,u_p.grade as grade,u_p.user_id as user_id,u_p.gender as gender, a.status,t.name as team_name,s.name as school_name from team_user_ships a INNER JOIN teams t on t.id = a.team_id inner join user_profiles u_p on u_p.user_id = a.user_id inner join schools s on s.id = u_p.school where a.team_id = #{a_p.team_id}")
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

  def update_user_info
    username = params[:username]
    gender = params[:gender]
    district = params[:district]
    school = params[:school]
    grade = params[:grade]
    birthday = params[:birthday]
    student_code = params[:student_code]
    identity_card = params[:identity_card]

    if /\A[\u4e00-\u9fa5]{2,4}\Z/.match(username)==nil
      result = [false, '姓名为2-4位中文']
    elsif school.to_i !=0 && grade.to_i !=0 && gender.present? && district.to_i != 0 && student_code.present? && birthday.present?
      if ([grade.to_i] & [10, 11, 12]).present? && /^[1-9]\d{5}[1-9]\d{3}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{3}([0-9]|X)$/.match(identity_card) == nil
        result = [false, '高中生请正确填写18位身份证号']
        render json: result
        return false
      end
      user = current_user.user_profile ||= current_user.build_user_profile
      if user.update_attributes(username: username, gender: gender, school_id: school, grade: grade, district_id: district, student_code: student_code, birthday: birthday, identity_card: identity_card)
        result = [true, '信息确认成功']
      else
        result = [false, '信息确认失败,请注意数据规范']
      end
    else
      result = [false, '个人信息输入不完整']
    end
    render json: result
  end

  def leader_create_team
    user_id = current_user.id
    team_name = params[:team_name]
    teacher = params[:team_teacher]
    school_id = params[:team_school]
    district_id = params[:team_district]
    ed = params[:team_event]
    group = params[:group]

    if params[:teacher_mobile].present?
      teacher_mobile = params[:teacher_mobile]
    else
      teacher_mobile=nil
    end
    unless team_name.length>1 && team_name.length<6
      render json: [false, '请输入2-5位的队伍名字']
      return false
    end

    if district_id !=0 && ed !=0 && teacher.present? && group != 0
      event = Event.joins(:competition).where(id: params[:ed]).select('competitions.apply_end_time').take
      if event.present?
        unless event.apply_end_time > Time.now
          render json: [false, '现在不是报名时间!']
          return false
        end
      else
        render json: [false, '参数不规范!']
        return false
      end
      already_apply = TeamUserShip.where(user_id: user_id, event_id: ed, status: true).exists?
      has_team_name = Team.where(event_id: ed, name: team_name).take
      if already_apply
        result = [false, '该比赛您已经报名，请不要再次报名!']
      elsif has_team_name.present?
        result = [false, '很抱歉，该比赛中队伍['+has_team_name.name+']已存在，请更改队伍名称!']
      else
        team = Team.create!(name: team_name, group: group, district_id: district_id, user_id: user_id, teacher: teacher, teacher_mobile: teacher_mobile, event_id: ed, school_id: school_id)
        if team.save
          user_info = current_user.user_profile
          team_user_ship = TeamUserShip.create!(team_id: team.id, user_id: team.user_id, event_id: ed, school_id: user_info.school_id, grade: user_info.grade, status: true)
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


  protected

  def set_competition
    @competition = Competition.find(params[:id])
  end
end
