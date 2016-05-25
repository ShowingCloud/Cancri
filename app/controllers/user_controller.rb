class UserController < ApplicationController
  before_action :authenticate_user!

  # 个人信息概览
  def preview
    @user_info = User.joins('left join user_profiles u_p on u_p.user_id = users.id').joins('left join schools s on s.id = u_p.school').where(id: current_user.id).select(:email, :mobile, 'u_p.username as name', 'u_p.gender as xb', 'u_p.grade', 'u_p.bj', 'u_p.roles as role', 's.name as school', 'u_p.address').take
  end

  # 修改个人信息
  def profile
    # 获取Profile
    @user_profile = current_user.user_profile ||= current_user.build_user_profile
    @th_role_status = UserRole.where(user_id: current_user.id, role_id: 1).first # 教师
    if request.method == 'POST'
      if params[:user_profile].present?
        # 过滤Profile参数
        profile_params = params.require(:user_profile).permit(:username, :school, :bj, :gender, :birthday, :address, :teacher_no, :certificate, :grade, :autograph, {:roles => []}).tap do |list|
          if params[:user_profile][:roles].present? && params[:user_profile][:roles] != '教师'
            list[:roles] = params[:user_profile][:roles].join(',')
          else
            list[:roles] = nil
          end
        end
        if ['高一', '高二', '高三'].include?(profile_params[:grade])
          unless /^[1-9]\d{5}[1-9]\d{3}((0\d)|(1[0-2]))(([0|1|2]\d)|3[0-1])\d{3}([0-9]|X)$/.match(profile_params[:identity_card]) != nil
            flash[:error] = '高中生请正确填写18位身份证号'
            return false
          end
        end
        message = ''
        if profile_params[:roles].present? && profile_params[:roles].include?('教师')
          unless profile_params[:teacher_no].present? && profile_params[:certificate].present? && profile_params[:school].present? && profile_params[:username].present?
            flash[:error] = '选择教师身份时，请填写姓名、学校、教师编号、和上传教师证件'
            return false
          end
          unless UserRole.where(user_id: current_user.id, role_id: 1).exists?
            th_role = UserRole.create!(user_id: current_user.id, role_id: 1, status: false) # 教师
            if th_role.save
              message = '您的老师身份已提交审核，审核通过后会在［消息］中告知您！'
            else
              message
            end
          end
        end
        if message=='-'
          message=''
        end
        @user_profile.username = profile_params[:username]
        @user_profile.autograph = profile_params[:autograph]
        @user_profile.school = profile_params[:school].to_i
        @user_profile.grade = profile_params[:grade]
        @user_profile.bj = profile_params[:bj]
        @user_profile.age = profile_params[:age]
        @user_profile.birthday = profile_params[:birthday]
        @user_profile.gender = profile_params[:gender].to_i
        @user_profile.address = profile_params[:address]
        @user_profile.roles = profile_params[:roles]
        @user_profile.teacher_no = profile_params[:teacher_no]
        @user_profile.certificate = profile_params[:certificate]
        if @user_profile.save
          flash[:success] = '更新成功'+message
        else
          flash[:error] = '更新失败'+message
        end
      else
        flash[:error] = '不能提交空信息'
      end
      redirect_to user_preview_path
    end
  end

  def check_email_exists
    render json: require_email
  end

  def check_mobile_exists
    render json: require_mobile
  end

  def check_email_and_mobile
    render json: require_email_and_mobile
  end

  def email
    if params[:return_uri].present?
      return_uri = params[:return_uri]
      session[:return_apply_event] = return_uri
    end
    if request.method == 'POST'
      current_user.email = params[:user][:email]
      ec = EmailService.new(params[:user][:email])
      status, message = ec.validate?(params[:email_code], EmailService::TYPE_CODE_ADD_EMAIL_CODE)
      if status
        current_user.email = params[:user][:email]
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
        current_user.email = params[:user][:email]
        flash[:error] = message
      end
    end
  end

  def mobile
    if request.method == 'POST'
      current_user.mobile_info = params[:user][:mobile_info]
      sms = SMSService.new(params[:user][:mobile_info])
      status, message = sms.validate?(params[:email_code], SMSService::TYPE_CODE_ADD_MOBILE)
      if status
        current_user.mobile = params[:user][:mobile_info]
        if current_user.save
          flash[:success] = '手机添加成功'
          redirect_to user_preview_path
        else
          flash[:error] = '手机添加失败'
        end
      else
        current_user.mobile_info = params[:user][:mobile_info]
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
    if request.method == 'POST' && verify_rucaptcha?(current_user)
      unless params[:mobile_info].present? && params[:email_code].present? && params[:password].present?
        flash[:error] = '请将手机号、手机验证码、密码填写完整'
        return
      end
      unless current_user.valid_password?(params[:password])
        flash[:error]='密码不正确'
        return
      end
      sms = SMSService.new(params[:mobile_info])
      status, message = sms.validate?(params[:email_code], SMSService::TYPE_CODE_ADD_MOBILE)
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
    @user_events = TeamUserShip.joins(:event, :team, :school).joins('inner join user_profiles u_p on u_p.user_id = team_user_ships.user_id').joins('inner join competitions comp on comp.id = events.competition_id').where(user_id: current_user.id, status: true).select(:user_id, :grade, 'events.name as event_name', 'comp.name as comp_name', 'schools.name as school_name', 'comp.status', 'u_p.student_code', 'u_p.username', 'teams.identifier', 'teams.teacher', 'teams.teacher_mobile')
  end

  def consult
    if request.method == 'POST'
      content = params[:consult][:content]
      if content.present? && content.length < 151 && content.length > 5
        consult = Consult.create(user_id: current_user.id, content: content)
        if consult.save
          flash[:success]='调戏成功'
          redirect_to user_consult_path
        else
          flash[:error]='提交失败'
        end
      else
        @consult = Consult.new(content: params[:consult][:content])
        flash[:error]='请填写6-150位字符的反馈内容'
      end
    end
    unless @consult.present?
      @consult = current_user.consults.build
    end
    @consults = Consult.where(user_id: current_user.id).all.order('id asc')
  end

  def point
    @user_points = UserPoint.joins(:prize).where(user_id: current_user.id).select(:id, :is_audit, 'prizes.name', 'prizes.host_year', 'prizes.point', 'prizes.prize')
  end

  def add_point
    @point = current_user.user_points.build
    if request.method == 'POST'
      u_p = UserPoint.create(user_id: current_user.id, prize_id: params[:user_point][:prize_id], cover: params[:user_point][:cover])
      if u_p.save
        flash[:success] = 'ok'
        redirect_to user_point_path
      else
        flash[:error] = 'fail'
      end
    end
  end


  def notification
    @notifications = current_user.notifications.page(params[:page]).per(params[:per]).order('created_at desc')
    if params[:id].present?
      @notification = Notification.find(params[:id])
    end
  end

  def notify_show
    @notification = current_user.notifications.where(id: params[:id]).take

    if @notification.present?
      ## 队长邀请队员
      if @notification.message_type==1 && @notification.team_id.present?
        @t_u = TeamUserShip.joins(:event).where(team_id: @notification.team_id, user_id: @notification.user_id).select(:id, :status, 'events.apply_end_time', :event_id).take
      end

      ## 申请加入队伍
      if @notification.message_type==2 && @notification.team_id.present? && @notification.reply_to.present? && @notification.t_u_id.present?
        @t_u = TeamUserShip.joins(:event).where(team_id: @notification.team_id, user_id: @notification.reply_to).select(:id, :status, 'events.apply_end_time', :event_id).take
        if @t_u.present?
          if @t_u.status
            @has_agree = true # 已同意
          else
            if !TeamUserShip.exists?(@t_u.id.to_i)
              @has_agree = 2 # 已拒绝
            else
              @has_agree = false # 未处理
            end
          end
        end
      end

      ## 申请退出比赛
      if @notification.message_type==3 && @notification.team_id.present? && @notification.reply_to.present?
        @t_u = TeamUserShip.joins(:event).where(team_id: @notification.team_id, user_id: @notification.reply_to).select(:id, :status, 'events.apply_end_time', :event_id).take
        if @t_u.present?
          @has_agree = false # 未处理或已拒绝退出
        else
          @has_agree = true # 已同意
        end
      end
    end
  end

  def agree_invite_info
    birthday = params[:birthday]
    username = params[:username]
    school = params[:school].to_i
    grade = params[:grade]
    bj = params[:bj]
    gender = params[:gender].to_i
    student_code = params[:student_code]
    identity_card = params[:identity_card]
    td = params[:td].to_i
    ed = params[:ed].to_i
    if td!=0 && ed !=0
      t_u = TeamUserShip.where(event_id: ed, team_id: td, user_id: current_user.id).take
      if t_u.status
        status = true
        message = '您已经是该队队员'
      else
        if username.present? && school!=0 && grade.present? && gender!=0 && birthday.present? && student_code.present? && bj.present?
          user = UserProfile.find_by(user_id: current_user.id)
          if user.present?
            user.username = username
            user.birthday = birthday
            user.school = school
            user.grade = grade
            user.bj = bj
            user.gender = gender
            user.student_code = student_code
            user.identity_card = identity_card

            if user.save
              status = true
              message = '个人信息确认成功'
            else
              status = false
              message = '个人信息更新失败'
            end
          else
            up = UserProfile.create!(user_id: t_u.user_id, username: username, bj: bj, school: school, grade: grade, gender: gender, birthday: birthday, student_code: student_code, identitty_card: identity_card)
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
        if status
          t_u.status= true
          if t_u.save
            message='接受成功'
          else
            message=message+'//但接受失败'
          end
        end
      end
    else
      status=false
      message = '队伍及附属参数不完整'
    end
    render json: [status, message]
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

  def add_school
    name = params[:school]
    district = params[:district]
    type = params[:type].to_i
    if name.present? && district.present? && type !=0
      school = School.where(name: name, district: district, school_type: type).take
      if school.present?
        result=[false, '该学校已存在或已被添加(待审核)']
      else
        has_add = School.where(user_id: current_user.id, status: 0).exists?
        if has_add.present?
          result= [false, '您已经添加过一所待审核学校，在审核前不能再次添加']
        else
          add_s = School.create!(name: name, district: district, school_type: type, school_city: '上海市', user_id: current_user.id, user_add: true, status: false)
          if add_s.save
            result=[true, '添加成功,该学校仅为您显示，审核通过后才能选择该学校', add_s.id]
          else
            result=[false, '添加学校失败']
          end
        end
      end
    else
      result = [false, '请将学校名称、类型、所属区县填写完整']
    end
    render json: result
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

end
