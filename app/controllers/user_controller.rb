class UserController < ApplicationController
  before_action :authenticate_user!

  # 个人信息概览
  def preview

  end

  # 修改个人信息
  def profile
    # 获取Profile
    @user_profile = current_user.user_profile ||= current_user.build_user_profile
    @th_role_status = UserRole.where(user_id: current_user.id, role_id: 1).first # 教师
    if request.method == 'POST'
      if params[:user_profile].present?
        # 过滤Profile参数
        profile_params = params.require(:user_profile).permit(:username, :school, :bj, :address, :teacher_no, :certificate, :grade, {:roles => []}).tap do |list|
          if params[:user_profile][:roles].present?
            list[:roles] = params[:user_profile][:roles].join(',')
          else
            list[:roles] = nil
          end
        end
        message = ''
        if profile_params[:roles].present? && profile_params[:roles].include?('教师')
          unless profile_params[:teacher_no].present? && profile_params[:certificate].present? && profile_params[:school].present? && profile_params[:username].present?
            flash[:error] = '选择教师身份时，请填写姓名、学校、教师编号、和上传教师证件'
            return false
          end
          th_role = UserRole.create!(user_id: current_user.id, role_id: 1) # 教师
          if th_role.save
            message = '您的老师身份已提交审核，审核通过后会在［消息］中告知您！'
          else
            message
          end
        end
        if message=='-'
          message=''
        end
        @user_profile.username = profile_params[:username]
        @user_profile.autograph = profile_params[:autograph]
        @user_profile.school = profile_params[:school]
        @user_profile.grade = profile_params[:grade]
        @user_profile.bj = profile_params[:bj]
        @user_profile.age = profile_params[:age]
        @user_profile.gender = profile_params[:gender]
        @user_profile.birthday = profile_params[:birthday]
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
      redirect_to user_profile_path
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


  def notification
    @notifications = current_user.notifications.page(params[:page]).per(params[:per]).order('created_at desc')
    if params[:id].present?
      @notification = Notification.find(params[:id])
    end
  end

  def notify_show
    @notification = current_user.notifications.where(id: params[:id]).take

    if @notification.present? && @notification.t_u_id.present? && !TeamUserShip.exists?(@notification.t_u_id.to_i)
      @has_agree = 2
    elsif @notification.present? && @notification.t_u_id.present? && TeamUserShip.find(@notification.t_u_id.to_i).status
      @has_agree = true
    else
      @has_agree = false
    end
    @event= Event.joins(:teams, :team_user_ships).where("teams.id=?", 1).where("events.id=teams.event_id").where("teams.id=team_user_ships.team_id").where("team_user_ships.user_id=?", current_user.id).select(:id, :status, "team_user_ships.status as invited").first
  end

  def agree_invite_info
    t_u = TeamUserShip.where(event_id: params[:ed], team_id: params[:td], user_id: current_user.id).take
    if t_u.status
      status = true
      message = '您已经是该队队员'
    else
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
      if status
        t_u.status= true
        if t_u.save
          message='接受成功'
        else
          message=message+'//但接受失败'
        end
      end
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
    redirect_to user_profile_path
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
    district = params[:district].to_i
    type = params[:type].to_i
    if name.present? && district !=0 && type !=0
      school = School.where(name: name, district: district, school_type: type).take
      if school.present?
        result=[false, '该学校已存在或已被添加(待审核)']
      else
        has_add = School.find_by_user_id(current_user.id)
        if has_add.present?
          result= [false, '您已经添加过一所学校，在未审核通过前不能再次添加']
        else
          add_s = School.create!(name: name, district: district, school_type: type, school_city: '上海市')
          if add_s.save
            result=[true, '添加成功', add_s.id] #该学校仅为您显示，审核通过后其他人才能选择该学校
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
