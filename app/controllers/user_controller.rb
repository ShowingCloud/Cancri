class UserController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:competitions, :courses, :activities]
  before_action :is_teacher, only: [:programs, :program, :program_se, :create_program, :course_score]

  # 个人信息概览
  def preview
    @user_info = User.joins('left join user_profiles u_p on u_p.user_id = users.id').joins('left join schools s on s.id = u_p.school_id').where(id: current_user.id).select(:email, :mobile, 'u_p.username as name', 'u_p.gender', 'u_p.grade', 'u_p.bj', 'u_p.roles as role', 'u_p.birthday', 's.name as school', 'u_p.address').take
  end


  # 修改个人信息
  def profile
    current_user_id = current_user.id
    # 获取Profile
    @user_profile = current_user.user_profile ||= current_user.build_user_profile
    @has_roles = UserRole.where(user_id: current_user_id).pluck(:role_id, :status)

    if request.method == 'POST'
      if params[:user_profile].present?
        # 过滤Profile参数
        profile_params = params.require(:user_profile).permit(:username, :school_id, :bj, :district_id, :gender, :birthday, :student_code, :identity_card, :address, :cover, :desc, :teacher_no, :certificate, :grade, :autograph)
        roles = params[:user_profile][:roles]
        username = profile_params[:username]
        autograph = profile_params[:autograph]
        school_id = profile_params[:school_id]
        district_id = profile_params[:district_id]
        grade = profile_params[:grade]
        bj = profile_params[:bj]
        student_code = profile_params[:student_code]
        identity_card = profile_params[:identity_card]
        birthday = profile_params[:birthday]
        gender = profile_params[:gender]
        address = profile_params[:address]
        teacher_no = profile_params[:teacher_no]
        certificate = profile_params[:certificate]

        message = ''
        if roles.present? && roles.include?('教师')
          unless school_id.present? && district_id.present? && username.present? && [1, 2].include?(gender.to_i)
            flash[:error] = '选择教师身份时，请填写姓名、性别、学校(区县)'
            return false
          end
          unless UserRole.where(user_id: current_user_id, role_id: 1).exists?
            th_role = UserRole.create(user_id: current_user_id, role_id: 1, status: 0, school_id: school_id, district_id: district_id, cover: certificate) # 教师
            if th_role.save
              message = '您的老师身份已提交审核，审核通过后会在［消息］中告知您！'
            else
              message = '您的老师身份申请出现意外'
            end
          end
        end
        if roles.present? && roles.include?('家庭创客')
          unless profile_params[:cover].present? && school_id.present? && username.present? && [1, 2].include?(gender.to_i)
            flash[:error] = '选择家庭创客身份时，请填写姓名、性别、学校、描述和图片'
            return false
          end
          unless UserRole.where(user_id: current_user_id, role_id: 2).exists?
            th_role = UserRole.create(user_id: current_user_id, role_id: 2, status: 0, cover: profile_params[:cover], desc: profile_params[:desc], school_id: school_id, district_id: district_id) # 家庭创客
            if th_role.save
              message = '您的家庭创客身份已提交审核，审核通过后会在［消息］中告知您！'
            else
              message
            end
          end
        end

        if message=='-'
          message=''
        end

        if @user_profile.update_attributes(username: username, birthday: birthday, gender: gender, address: address, teacher_no: teacher_no, autograph: autograph, school_id: school_id, district_id: district_id, grade: grade, bj: bj, student_code: student_code, identity_card: identity_card)
          flash[:success] = '更新成功-'+message
          redirect_to user_profile_path
        else
          flash[:error] = '更新失败-'+message
        end
      else
        flash[:error] = '不能提交空信息'
      end
    end
  end

  def competitions
    @competitions = TeamUserShip.joins(:team, :event).left_joins(:school).joins('left join user_profiles up on up.user_id = team_user_ships.user_id').joins('left join competitions c on c.id = events.competition_id').where('c.end_time < ?', Time.now).where(user_id: @user.id, status: true).select('team_user_ships.grade', 'schools.name as school_name', 'up.username', 'up.bj', 'up.student_code', 'c.name as comp_name', 'c.organizing_committee', 'c.start_time', 'c.end_time', 'events.name as event_name', 'teams.identifier', 'teams.last_score').page(params[:page]).per(params[:per])
  end

  def courses
    @courses = CourseUserShip.left_joins(:school, :course).joins('left join user_profiles up on up.user_id=course_user_ships.user_id').where('courses.end_time < ?', Time.now).where(user_id: @user.id).select(:score, :grade, 'up.username', 'up.student_code', 'courses.name', 'courses.end_time', 'schools.name as school_name').page(params[:page]).per(params[:per])
  end

  def activities
    @activities = ActivityUserShip.left_joins(:activity, :school).joins('left join user_profiles up on up.user_id = activity_user_ships.user_id').where('activities.end_time < ?', Time.now).where(user_id: @user.id).select(:score, :grade, :has_join, 'up.username', 'activities.name', 'activities.start_time', 'activities.end_time', 'schools.name as school_name').page(params[:page]).per(params[:per])
  end


  def apply
    type = params[:type] ## option default: competition
    current_user_id = current_user.id
    if type.present?
      case type
        when 'competition' then
          @apply_info = TeamUserShip.joins(:team, :event).left_joins(:school).joins('left join user_profiles up on up.user_id = team_user_ships.user_id left join competitions c on c.id = events.competition_id').where('c.end_time > ?', Time.now).where(user_id: current_user_id).select(:id, 'up.username', :grade, 'up.gender', 'up.birthday', 'up.bj', 'up.student_code', 'up.identity_card', 'schools.name as school_name', 'c.name as comp_name', 'c.start_time', 'events.name as event_name', 'events.id as event_id', 'teams.last_score', 'teams.identifier', 'teams.group', 'teams.teacher', 'teams.status as team_status', 'teams.teacher_mobile').page(params[:page]).per(params[:per])
        when 'activity' then
          @apply_info = ActivityUserShip.joins(:activity).left_joins(:school).where('activities.end_time > ?', Time.now).where(user_id: current_user_id).select(:id, :has_join, 'schools.name as school_name', 'activity_user_ships.grade', 'activities.*').page(params[:page]).per(params[:per])
        else
          render_optional_error(404)
      end
    else
      @apply_info = CourseUserShip.joins(:course).joins('left join user_profiles up on up.user_id=course_user_ships.user_id').where('courses.end_time > ?', Time.now).where(user_id: current_user_id).select(:score, :course_id, 'up.username', 'up.grade', 'up.bj', 'up.student_code', 'courses.name', 'courses.end_time').page(params[:page]).per(params[:per])
    end
  end

  def programs
    @courses = Course.where(user_id: current_user.id).order('id desc').page(params[:page]).per(8)
  end

  def program
    course = Course.find(params[:id])
    if course && course.user_id == current_user.id
      @apply_info = CourseUserShip.includes(:course_user_scores).joins(:course, :user).where(course_id: params[:id]).left_joins(:school).joins('left join user_profiles u_p on course_user_ships.user_id = u_p.user_id').joins('left join districts d on u_p.district_id = d.id').select(:id, :user_id, :course_id, :grade, :score, 'courses.name as course_name', 'u_p.username', 'd.name as district_name', 'courses.end_time', 'users.mobile', 'schools.name as school_name').page(params[:page]).per(params[:per])
      @course_score_attrs = CourseScoreAttribute.where(course_id: params[:id]).select(:id, :course_id, :name, :score_per).to_a
    else
      render_optional_error(404)
    end
  end

  def get_user_course_score
    @user_course_scores = CourseUserScore.where(course_id: params[:cd], user_id: params[:ud])
  end

  def create_program
    @course = Course.new
    if request.method == 'POST'
      params_program
    end
  end

  def program_se
    course = Course.find(params[:id])
    if course && course.user_id == current_user.id
      @course = course
    else
      render_optional_error(403)
    end
    if request.method == 'POST'
      params_program
    end

  end

  def course_ware
    @course = Course.find(params[:id])
    if request.method=='POST'
      if @course.user_id == current_user.id
        cf_params=params.require(:course_file).permit(:course_ware, :course_id)
        @course_file = CourseFile.new(cf_params)
        if @course_file.save
          flash[:success]='课件上传成功!'
          redirect_to "/user/course_ware/#{params[:course_file][:course_id]}"
        else
          @course_file.course_id = params[:course_file][:course_id]
          flash[:success]='课件上传失败,请留意文件格式!'
        end
      else
        render_optional_error(403)
      end
    else
      @course_files = @course.course_files
      @course_file = CourseFile.new(course_id: @course.id)
    end
  end

  def course_score
    course_ud = params[:course_ud].to_i
    last_score = params[:last_score]
    score_attrs = params[:score_attrs]
    unless last_score.present?
      score_attrs = score_attrs.try(:to_unsafe_h)
    end

    if course_ud !=0 && (last_score.present? || score_attrs.present?)
      course_user = CourseUserShip.find(course_ud)
      course = course_user.course
      if course.user_id == current_user.id
        course_score_attrs = course.course_score_attributes.pluck(:id)
        if (Time.now > (course.end_time + 5.days)) || (Time.now < course.end_time)
          result = [false, '现在不是登记成绩时间']
        else

          if course_score_attrs.length==0 && last_score.present?
            course_user.score = last_score
            if course_user.save
              result = [true, '操作成功']
            else
              result = [false, '操作失败']
            end
          elsif course_score_attrs.length!=0 && score_attrs.is_a?(Hash) && (course_score_attrs & score_attrs.keys.map { |x| x.to_i } == course_score_attrs)
            status = []
            sum_score = 0
            score_attrs.each do |s|
              sum_score += s[1].to_i
              score = CourseUserScore.where(course_sa_id: s[0], course_user_ship_id: course_ud).take
              if score.present?
                score.score = s[1]
                status << score.save
              else
                status << CourseUserScore.create(course_sa_id: s[0], course_user_ship_id: course_ud, score: s[1]).save
              end
            end
            if status.uniq == [true]
              course_user.score = sum_score
              if course_user.save
                result = [true, '操作成功']
              else
                result = [false, '操作失败']
              end
            else
              CourseUserScore.where(course_user_ship_id: course_ud).delete_all
              course_user.score = nil
              course_user.save
              result = [false, '操作失败,请重新输入成绩']
            end
          else
            result = [false, '参数不规范']
          end
        end
      else
        render_optional_error(403)
      end
    else
      result = [false, '参数不完整或不规范']
    end
    render json: result
  end

  def student_manage
    current_user_id =current_user.id
    @teacher_info = UserRole.where(role_id: 1, status: 1, user_id: current_user_id).select(:role_type, :school_id, :district_id).take
    if @teacher_info.present?
      students = UserProfile.left_joins(:district, :school, :user).where.not(user_id: current_user_id).select(:username, :grade, :gender, :student_code, 'schools.name as school_name', 'districts.name as district_name', 'users.nickname'); false
      if @teacher_info.role_type == 2
        students = students.where(district_id: @teacher_info.district_id)
      elsif @teacher_info.role_type == 3
        students = students.where(school_id: @teacher_info.school_id)
      end
      @students = students.page(params[:page]).per(params[:per])
    else
      render_optional_error(403)
    end
  end

  def comp_student
    @teacher_info = UserRole.where(role_id: 1, status: 1, user_id: current_user.id).select(:role_type, :school_id, :district_id).take
    if @teacher_info.present?
      @competitions = Competition.where(status: 1).select(:id, :name, :apply_end_time, :school_audit_time, :district_audit_time)
    else
      render_optional_error(403)
    end
  end

  def get_comp_students
    comp_id = params[:com]
    ed = params[:ed]
    school_id = params[:s]
    status = params[:status]
    teacher_info = UserRole.where(role_id: 1, status: 1, user_id: current_user.id).select(:role_type, :school_id, :district_id).take
    if teacher_info.present?
      if comp_id.present?
        competition = Competition.where(id: comp_id, status: 1).first
        if competition.present?
          students = TeamUserShip.joins(:event, :school, :team, :user).joins('left join competitions c on c.id = events.competition_id').joins('left join user_profiles u_p on u_p.user_id = team_user_ships.user_id').select('team_user_ships.grade', 'teams.id as team_id', 'team_user_ships.user_id', 'teams.user_id as leader_user_id', 'teams.group', 'teams.teacher', 'teams.identifier ', 'events.name as event_name', ' u_p.username ', ' u_p.gender ', ' users.nickname ', 'users.mobile', 'schools.name as school_name').order('teams.group asc, teams.id, team_user_ships.id asc')
          if teacher_info.role_type == 2
            case status
              when '0' then
                students = students.where('teams.status=?', -3)
              when '1' then
                students = students.where('teams.status=?', 1)
              else
                students = students.where('teams.status': [2, 3, -3])
            end
            students = students.where('teams.district_id=?', teacher_info.district_id)
            if school_id.present? && school_id.to_i !=0 && (School.find_by_id(school_id).try(:district_id) == teacher_info.district_id)
              students = students.where('teams.school_id = ?', school_id)
            end
          elsif teacher_info.role_type == 3
            case status
              when '0' then
                students = students.where('teams.status=?', -2)
              when '1' then
                students = students.where('teams.status': [3, 1, -3])
              else
                students = students.where('teams.status=?', 2)
            end
            students = students.where('teams.school_id=?', teacher_info.school_id)
          elsif teacher_info.role_type == 1
            if school_id.present? && school_id.to_i !=0
              students = students.where('teams.school_id = ?', school_id)
            end
            students = students.where('teams.status = ?', 1)
          end

          if students.length>0
            if ed.present? && (ed.to_i !=0)
              students = students.where('teams.event_id = ?', ed)
            else
              students = students.where('c.id = ?', comp_id)
            end
            if students.length>0
              page_students = students.page(params[:page]).per(10)
              result = [true, page_students, students.length, competition]
            else
              result = [false, '没有相关队伍']
            end
          else
            result = [false, '没有相关队伍']
          end
        else
          result = [false, '不规范请求']
        end
      else
        result = [false, '参数不完整']
      end
    else
      result = [false, '403']
    end
    respond_to do |format|
      format.json { render json: result }
      format.xls {
        if students.present?
          data = students.map { |x| {
              项目: x.event_name,
              组别: case x.group
                    when 1 then
                      '小学'
                    when 2 then
                      '中学'
                    when 3 then
                      '初中'
                    when 4 then
                      '高中'
                    else
                  end,
              队伍: x.leader_user_id == x.user_id ? x.identifier : nil,
              姓名: x.username,
              性别: case x.gender
                    when 1 then
                      '男'
                    when 2 then
                      '女'
                    else
                  end,
              学校: x.school_name,
              指导老师: x.teacher,
              手机: x.mobile,
              年级: x.grade
          } }
          filename = "#{data.first[:项目]}-#{Time.now.strftime("%Y%m%d%H%M%S")}.xls"
          send_data(data.to_xls, :type => "text/xls;charset=utf-8,header=present", :filename => filename)
        end
      }
    end
  end


  def export_voucher
    @apply_info = TeamUserShip.joins(:team, :event).left_joins(:school).joins('left join user_profiles up on up.user_id = team_user_ships.user_id left join competitions c on c.id = events.competition_id').where('events.id=?', params[:ed]).where('c.end_time > ?', Time.now).where(user_id: current_user.id).select(:id, 'up.username', :grade, 'up.gender', 'up.birthday', 'up.identity_card', 'schools.name as school_name', 'c.name as comp_name', 'c.start_time', 'events.name as event_name', 'teams.identifier', 'teams.group', 'teams.teacher', 'teams.teacher_mobile').take
    pdf = render_to_string pdf: 'pdfs', template: 'user/export_voucher.html.erb', layout: 'pdf', formats: :pdf, encoding: 'UTF-8', :disposition => 'inline'
    send_data(pdf, filename: "#{@apply_info.identifier}_#{@apply_info.event_name}_#{@apply_info.username}.pdf", :type => 'application/pdf')
  end


  def cancel_apply
    if request.method == 'POST'
      type = params[:t].to_i
      identifier = params[:identifier]
      no_rule = [false, '不规范请求', type]
      if type.present? && identifier.present?
        case type
          when 1 then
            c_u = CourseUserShip.find(identifier)
            if c_u.present? && (c_u.user_id == current_user.id)
              if c_u.destroy
                result = [true, '取消成功', type, identifier]
              else
                result = [false, '取消失败', type]
              end
            else
              result = no_rule
            end
          else
            result = no_rule
        end
      else
        result = no_rule
      end
    else
      result = [false, '非法请求']
    end
    render json: result
  end

  def email
    if params[:return_uri].present?
      return_uri = params[:return_uri]
      session[:return_apply_event] = return_uri
    end
    if request.method == 'POST'
      current_user.email_info = params[:user][:email_info]
      ec = EmailService.new(params[:user][:email_info])
      status, message = ec.validate?(params[:email_code], EmailService::TYPE_CODE_ADD_EMAIL_CODE)
      if status
        current_user.email = params[:user][:email_info]
        if current_user.save
          flash[:success] = '邮箱添加成功'
          if session[:return_apply_event].present?
            redirect_to session[:return_apply_event]
            session[:return_apply_event] = nil
          else
            redirect_to user_preview_path
          end
        else
          flash[:error] = '邮箱添加失败'
        end
      else
        current_user.email_info = params[:user][:email_info]
        flash[:error] = message
      end
    end
  end

  def mobile
    if request.method == 'POST'
      current_user.mobile_info = params[:user][:mobile_info]
      sms = SMSService.new(params[:user][:mobile_info])
      status, message = sms.validate?(params[:user][:email_code], SMSService::TYPE_CODE_ADD_MOBILE)
      if status
        current_user.mobile = params[:user][:mobile_info]
        if current_user.save
          flash[:success] = '手机添加成功'
          redirect_to session[:redirect_to].present? ? session[:redirect_to] : user_preview_path
          session[:redirect_to] = nil
        else
          flash[:error] = '手机添加失败'
        end
      else
        current_user.mobile_info = params[:user][:mobile_info]
        current_user.email_code = params[:user][:email_code]
        flash[:error] = message
      end
    end
  end

  def reset_mobile
    if params[:mobile_info].present?
      current_user.mobile_info = params[:mobile_info]
    end
    if params[:email_code].present?
      current_user.email_code = params[:email_code]
    end
    if request.method == 'POST' # && verify_rucaptcha?(current_user)
      unless params[:mobile_info].present? && params[:email_code].present? && params[:password].present?
        flash[:error] = '请将手机号、手机验证码、密码填写完整'
        return
      end
      unless current_user.valid_password?(params[:password])
        flash[:error]='密码不正确'
        return
      end
      sms = SMSService.new(params[:mobile_info])
      status, message = sms.validate?(params[:email_code], SMSService::TYPE_CODE_RESET_MOBILE)
      if status
        current_user.mobile = params[:mobile_info]
        if current_user.save
          flash[:success] = '手机更新成功'
          redirect_to user_preview_path
        else
          flash[:error] = '手机更新失败'
        end
      else
        flash[:error] = message
      end
    end
  end

  def reset_email
    if params[:email_info].present?
      current_user.email_info = params[:email_info]
    end
    if params[:email_code].present?
      current_user.email_code = params[:email_code]
    end
    if request.method == 'POST' && verify_rucaptcha?(current_user)
      unless params[:email_info].present? && params[:email_code].present? && params[:password].present?
        flash[:error] = '请将邮箱、邮箱验证码、密码填写完整'
        return
      end
      unless current_user.valid_password?(params[:password])
        flash[:error]='密码不正确'
        return
      end
      es = EmailService.new(params[:email_info])
      status, message = es.validate?(params[:email_code], EmailService::TYPE_CODE_ADD_EMAIL_CODE)
      if status
        current_user.email = params[:email_info]
        if current_user.save
          flash[:success] = '邮箱更新成功'
          redirect_to user_preview_path
        else
          flash[:error] = '邮箱更新失败'
        end
      else
        flash[:error] = message
      end
    end
  end

  def comp
  end

  def consult
    current_user_id = current_user.id
    if request.method == 'POST'
      content = params[:consult][:content]
      if content.present? && content.length < 256 && content.length > 5
        consult = Consult.create!(user_id: current_user_id, content: content)
        if consult.save
          flash[:success]='调戏成功'
          redirect_to user_consult_path
        else
          flash[:error]='提交失败'
        end
      else
        @consult = Consult.new(content: content)
        flash[:error]='请填写6-255位字符的反馈内容'
      end
    end
    unless @consult.present?
      @consult = current_user.consults.build
    end
    @consults = Consult.where(user_id: current_user_id).all.order('id asc')
  end

  def point
    # @user_points = UserPoint.joins(:prize).where(user_id: current_user.id).select(:id, :is_audit, 'prizes.name', 'prizes.host_year', 'prizes.point', 'prizes.prize')
  end

  # def add_point
  #   @point = current_user.user_points.build
  #   if request.method == 'POST'
  #     u_p = UserPoint.create(user_id: current_user.id, prize_id: params[:user_point][:prize_id], cover: params[:user_point][:cover])
  #     if u_p.save
  #       flash[:success] = 'ok'
  #       redirect_to user_point_path
  #     else
  #       flash[:error] = 'fail'
  #     end
  #   end
  # end


  def notification
    @notifications = current_user.notifications.page(params[:page]).per(params[:per]).order('created_at desc')
    if params[:id].present?
      @notification = Notification.find(params[:id])
    end
  end

  def notify_show
    @notification = current_user.notifications.find(params[:id])

    if @notification.present?
      ## 队长邀请队员
      if @notification.message_type==1 && @notification.team_id.present?
        @t_u = TeamUserShip.joins(:team, :event).joins('left join competitions c on c.id = events.competition_id').where(team_id: @notification.team_id, user_id: @notification.user_id).select('events.id as id', 'team_user_ships.status as t_u_status', 'teams.status as team_status', 'c.apply_end_time').take
        if @t_u.present? && (@t_u.apply_end_time>Time.now) && (@t_u.team_status == 0) && (@t_u.t_u_status==0)
          user_info = UserProfile.left_joins(:school, :district).where(user_id: @notification.user_id).select('user_profiles.*', 'schools.name as school_name', 'districts.name as district_name').take; false
          @user_info = user_info ||= current_user.build_user_profile
        end
      end

      ## 申请加入队伍
      if @notification.message_type==2 && @notification.team_id.present? && @notification.reply_to.present? && @notification.t_u_id.present?
        @t_u = TeamUserShip.joins(:team, :event).joins('left join competitions c on c.id = events.competition_id').where(team_id: @notification.team_id, user_id: @notification.reply_to).select('events.id as id', 'team_user_ships.status as t_u_status', 'teams.status as team_status', 'c.apply_end_time').take
      end

      ## 申请退出比赛
      if @notification.message_type==3 && @notification.team_id.present? && @notification.reply_to.present?
        @t_u = TeamUserShip.joins(:event).joins('left join competitions c on c.id = events.competition_id').where(team_id: @notification.team_id, user_id: @notification.reply_to).select(:id, :status, 'c.apply_end_time', :event_id).take
        if @t_u.present?
          @has_agree = false # 未处理或已拒绝退出
        else
          @has_agree = true # 已同意
        end
      end
    end
  end


  def passwd
    if request.method == 'POST'
      status, message = self.change_password(params[:user][:old_password], params[:user][:new_password], params[:user][:password_confirmation])
      if status
        flash[:success] = message
        redirect_to new_user_session_path
      else
        flash[:error] = message
      end
    end
  end


  # 更新头像和 nickname
  def update_avatar
    if params[:user].present?
      if current_user.update_attributes(params.require(:user).permit(:nickname, :avatar))
        flash[:success] = '个人信息更新成功'
      elsif User.where(nickname: params[:user][:nickname]).where.not(id: current_user.id).take.present?
        flash[:error] = params[:user][:nickname]+'已被使用,请使用其他昵称!'
      else
        flash[:error] = '个人信息更新失败'
      end
    else
      flash[:error] = '昵称不能为空'
    end
    redirect_to user_preview_path
  end

  # 头像删除
  def remove_avatar
    if current_user.avatar?
      current_user.remove_avatar!
      current_user.avatar = nil
      current_user.save
      flash[:success] = '头像已成功删除'
    end
    redirect_to user_profile_path
  end

  def role_apply
    @user_roles = UserRole.left_joins(:school).where(role_id: 1, user_id: current_user.id).select('user_roles.*', 'schools.name as school_name')
  end

  def apply_teacher
    role_type = params[:user_role_type]
    school_id = params[:user_school_id]
    certificate = params[:user_certificate]
    user_id = current_user.id
    user_role = UserRole.where(user_id: user_id, role_id: 1).take
    if user_role.present?
      user_role.update_attributes(role_type: role_type, desc: certificate, school_id: school_id, status: 0)
    else
      user_role = UserRole.create(user_id: user_id, role_id: 1, role_type: role_type, desc: certificate, school_id: school_id, status: 0)
    end
    respond_to do |format|
      if user_role.save
        format.html { redirect_to '/user/role_apply', notice: '申请成功，审核结果将消息告知您' }
        format.json { render json: {status: true, message: '申请成功，审核结果将消息告知您'} }
      else
        format.html { redirect_to '/user/role_apply', notice: user_role.errors.full_messages[0] }
        format.json { render json: {status: false, message: user_role.errors.full_messages[0]} }
      end
    end
  end

  def hacker_apply
    hacker = UserRole.joins(:user).left_joins(:school).joins('left join user_profiles u_p on u_p.user_id = user_roles.user_id').where(role_id: 2, user_id: current_user.id).select('user_roles.*', 'users.mobile', 'u_p.username', 'u_p.gender', 'u_p.birthday', 'u_p.position', 'u_p.identity_card', 'u_p.address', 'schools.name as school_name').take
    if hacker.present?
      @hacker = {status: hacker.status, mobile: hacker.mobile, profile: {username: hacker.username, gender: hacker.gender, birthday: hacker.birthday, school_name: hacker.school_name, school_id: hacker.school_id, position: hacker.position, identity_card: hacker.identity_card, address: hacker.address}, hacker: hacker.user_hacker, family: hacker.user_family, role_type: hacker.role_type, not_update: true}
    else
      profile = current_user.user_profile ||= current_user.build_user_profile
      hacker = current_user.build_user_hacker
      family = current_user.build_user_family
      @hacker = {profile: profile, hacker: hacker, family: family}
    end
  end

  def hacker_apply_post
    profile = params[:user_profile]
    family = params[:user_family]
    hacker = params[:hacker]
    role_type = params[:hacker_type]
    school_id = profile[:school_id]
    update = params[:update]
    if update == 'true'
      return_url = '/user/hacker_apply?update=true'
    else
      return_url = '/user/hacker_apply'
    end
    @hacker = {family: family, role_type: role_type, profile: profile, hacker: hacker}
    if role_type == '2' && current_user.mobile.nil?
      flash[:notice] = '申请社会创客时需认证手机！'
      redirect_to '/user/mobile'
    else
      if profile[:username].present? && profile[:birthday].present? && school_id.present? && profile[:gender].present?
        begin
          UserHacker.transaction do
            user_profile = current_user.user_profile ||= current_user.build_user_profile
            user_profile.update!(user_profile_params)
            user_role = current_user.user_roles.where(role_id: 2).take || current_user.user_roles.build
            user_role.update!(role_id: 2, role_type: role_type, school_id: school_id, status: 0)
            user_family = user_role.user_family || user_role.build_user_family
            user_hacker = user_role.user_hacker || user_role.build_user_hacker
            user_family.update!(user_id: user_role.user_id, father_name: family[:father_name], mother_name: family[:mother_name], address: family[:address], wx: family[:wx], qq: family[:qq], email: family[:email])
            user_hacker.update!(create_date: hacker[:create_date], user_id: user_role.user_id, square: hacker[:square], situation: hacker[:situation], partake: hacker[:partake], active_weekly: hacker[:active_weekly], family_hobbies: hacker[:family_hobbies], create_way: hacker[:create_way], create_with: hacker[:create_with])
          end
          flash[:notice] = '申请成功，审核结果将通过消息告知您！'
          redirect_to return_url
        rescue Exception => ex
          flash[:notice] = ex.message[5..-1]
          render return_url
        end
      else
        flash[:notice] = '请将姓名、性别、生日、学校填写完整！'
        render return_url
      end
    end
  end


  def get_schools
    district_id = params[:district_id]
    schools = School.where(status: 1, district_id: district_id).select(:id, :name, :teacher_role)
    render json: schools
  end

  def add_school
    name = params[:school]
    district = params[:district]
    # type = params[:type].to_i
    if name.present? && district.present?
      school = School.where(name: name, district_id: district).take
      if school.present?
        result=[false, '该学校已存在或已被添加(待审核)']
      else
        current_user_id = current_user.id
        has_add = School.where(user_id: current_user_id, status: 0).exists?
        if has_add.present?
          result= [false, '您已经添加过一所待审核学校，在审核前不能再次添加']
        else
          add_s = School.create(name: name, district_id: district, user_id: current_user_id, user_add: true, status: false)
          if add_s.save
            result=[true, '添加成功,该学校仅为您显示，审核通过后才能选择该学校', add_s.id]
          else
            result=[false, '添加学校失败']
          end
        end
      end
    else
      result = [false, '请将学校名称、所属区县填写完整']
    end
    render json: result
  end

  def get_districts
    render json: District.sh_districts.select(:id, :name, :city_name)
  end

  def get_competitions
    status = params[:status] ## option only 1/2
    result = Competition.where.not(status: 0).select(:id, :name, :apply_end_time, :school_audit_time, :district_audit_time)
    if status.present? && ([1, 2] & [status.to_i]).count > 0
      result = result.where(status: status)
    end
    render json: result
  end

  def get_events
    render json: Event.where(status: 1, is_father: 0, competition_id: params[:cd]).select(:id, :name)
  end

  #修改密码方法
  def change_password(old_password, new_password, confirm_password)
    unless old_password.present?
      return [FALSE, '原密码不能为空']
    end

    unless new_password.present?
      return [FALSE, '新密码不能为空']
    end

    unless new_password.length <= 30 && new_password.length >= 6
      return [FALSE, '新密码只能为6-30位']
    end

    unless confirm_password == new_password
      return [FALSE, '新密码两次输入不一致']
    end

    unless /\A[\x21-\x7e]+\Z/.match(confirm_password) != nil
      return [FALSE, '密码只包含数字、字母、特殊字符']
    end

    if current_user.valid_password?(old_password)
      current_user.password = new_password
      if current_user.save
        [TRUE, '密码已成功修改，请重新登录。']
      else
        [FALSE, '密码修改过程出错']
      end
    else
      [FALSE, '原密码不正确']
    end
  end

  def send_email_code
    ec = EmailService.new(params[:email])
    data = ec.send_email_code('ADD_EMAIL', request.ip)
    render json: data
  end

  def send_add_mobile_code
    sms = SMSService.new(params[:mobile])
    data = sms.send_code('ADD_MOBILE', request.ip)
    render json: data
  end

  private

  def set_user
    id = params[:id]
    if id.present?
      if id =~ /\A[\u4e00-\u9fa5_a-zA-Z0-9]+\Z/
        @user = User.find_by_nickname(id)
      else
        render_optional_error(404)
      end
    else
      @user = current_user
    end
    unless @user
      render_optional_error(404)
    end
  end

  def user_profile_params
    params.require(:user_profile).permit(:username, :birthday, :gender, :school_id, :identity_card, :position, :address)
  end

  def user_family_params
    params.require(:user_family).permit(:username, :birthday, :gender, :school_id, :identity_card, :position)
  end

  def params_program
    course_params = params.require(:course).permit(:name, :num, :target, :run_address, :run_time, :desc, :apply_start_time, :apply_end_time, :start_time, :end_time, :district_id)
    @course.name = course_params[:name]
    @course.num = course_params[:num]
    @course.district_id = course_params[:district_id]
    @course.run_address = course_params[:run_address]
    @course.run_time = course_params[:run_time]
    @course.apply_start_time = course_params[:apply_start_time]
    @course.apply_end_time = course_params[:apply_end_time]
    @course.target = course_params[:target]
    @course.user_id = current_user.id
    @course.desc = course_params[:desc]
    @course.start_time = course_params[:start_time]
    @course.end_time = course_params[:end_time]

    if @course.save
      flash[:success] = '操作成功!'
      if action_name == 'program_se'
        redirect_to user_program_se_path
      else
        redirect_to user_programs_path
      end
    else
      flash[:notice] = '操作失败!'
    end
  end

end
