class UserController < ApplicationController
  before_action :authenticate_user!

  # 个人信息概览
  def preview

  end

  # 修改个人信息
  def profile
    # 获取Profile
    @user_profile = current_user.user_profile ||= current_user.build_user_profile
    if request.method == 'POST'
      # 过滤Profile参数
      profile_params = params.require(:user_profile).permit(:username, :autograph, :age, :school, :grade, :gender, :bj, :birthday, :address)
      @user_profile.username = profile_params[:username]
      @user_profile.autograph = profile_params[:autograph]
      @user_profile.school = profile_params[:school]
      @user_profile.grade = profile_params[:grade]
      @user_profile.bj = profile_params[:bj]
      @user_profile.age = profile_params[:age]
      @user_profile.gender = profile_params[:gender]
      @user_profile.birthday = profile_params[:birthday]
      @user_profile.address = profile_params[:address]
      if @user_profile.save
        flash[:success] = '详细信息更新成功'
      else
        flash[:error] = '详细信息更新失败'
      end
      redirect_to user_profile_path
    end
  end

  def email
    # @current_email = current_user ||= current_user.build_user_profile

    @current_email = User.new
    if request.method == 'POST'
      @current_email.email = params[:email]
      ec = EmailService.new(params[:email])
      status, message = ec.validate?(params[:email_code], EmailService::TYPE_CODE_ADD_EMAIL_CODE)
      if status
        profile_params = params.require(:user).permit(:email)
        @current_email.email = profile_params[:email]
        if @current_email.save
          flash[:success] = '邮箱添加成功'
        else
          flash[:error] = '邮箱添加失败'
        end
      else
        @current_email.email = params[:email]
        flash[:error] = message
      end

      redirect_to user_email_path
    end
  end


  # 更新头像和 nickname
  def update_avatar
    if current_user.update_attributes(params.require(:user).permit(:nickname, :avatar))
      flash[:success] = '个人信息更新成功'
    elsif User.where(nickname: params[:user][:nickname]).where.not(id: current_user.id).take.present?
      flash[:error] = params[:user][:nickname]+'已被使用,请使用其他昵称!'
    else
      flash[:error] = '个人信息更新失败'
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


  # 修改密码请求
  def passwd
    if request.method == 'POST'

      status, message = self.change_password(current_user.nickname, params[:user][:old_password], params[:user][:new_password], params[:user][:confirm_password])
      if status
        sign_out @user
        redirect_to new_user_session_path

        flash[:success] = message
      else
        flash[:error] = message
      end
    end
  end

  #修改密码方法
  def change_password(nickname, old_password, new_password, confirm_password)
    user = User.find_by_nickname(nickname)
    unless user.present?
      return [FALSE, '用户不存在']
    end

    unless old_password.present?
      return [FALSE, '原密码不能为空']
    end

    unless new_password.present?
      return [FALSE, '新密码不能为空']
    end

    unless new_password.length <= 20 && new_password.length >= 6
      return [FALSE, '新密码只能为6-20位']
    end

    unless confirm_password == new_password
      return [FALSE, '新密码两次输入不一致']
    end

    unless user.valid_password?(old_password)
      return [FALSE, '原密码不正确']
    end


    if user.valid_password?(old_password)
      user.password = new_password
      if user.save
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
    data = ec.send_email_code(params[:email], params[:type], params[:ip])
    render json: data
  end

end
