class UserController < ApplicationController
  before_action :authenticate_user!

  before_action do
    @channel = '/channel'
    if params[:user_id].present?
      @channel += '/' + params[:user_id]
    end
  end

  before_action do
    $chats ||= {}
    $chats[@channel] ||= []
  end


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

  def comp
    @user_events = TeamUserShip.includes(:event).where(user_id: current_user.id).select(:id, :event_id, :team_id).page(params[:page]).per(5)
  end

  def comp_show
    @no_access = TeamUserShip.where(user_id: current_user.id, team_id: params[:id]).exists?
    if @no_access
      @team = Team.find(params[:id])
      @players = TeamUserShip.includes(:user).where(team_id: params[:id])
      @team_scores = Score.includes(:schedule, :team1, :team2).where(['team1_id = :value OR team2_id = :value', {:value => 3}]).select(:team1_id, :team2_id, :score1, :score2, :th, :comp_name, :kind).map { |s| {
          team1: s.team1.identifier,
          team2: s.team2.identifier,
          identifier1: s.team1.identifier,
          identifier2: s.team2.identifier,
          cover1: ActionController::Base.helpers.asset_path(s.team1.cover_url(:small)),
          cover2: ActionController::Base.helpers.asset_path(s.team2.cover_url(:small)),
          score1: s.score1,
          score2: s.score2,
          th: s.th.to_s,
          comp_name: s.schedule.name,
          kind: t('kind.kind'+s.kind.to_s)
      } }
    end
  end

  def creative_activity
    @creative_activities = CreativeActivity.where(user_id: current_user.id).page(params[:page]).per(params[:per])
  end

  def activity_show
    @creative_activity = CreativeActivity.find(params[:id])
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

  # 修改手机号
  def mobile
    @reset_mobile = ResetMobile.new
    if request.method == 'POST'
      @reset_mobile.password = params[:reset_mobile][:password]
      @reset_mobile.new_mobile = params[:reset_mobile][:new_mobile]
      @reset_mobile.mobile_code = params[:reset_mobile][:mobile_code]
      status, message = self.change_mobile(current_user.mobile, params[:reset_mobile][:new_mobile], params[:reset_mobile][:password], params[:reset_mobile][:mobile_code])

      if status
        sign_out @user
        redirect_to new_user_session_path

        flash[:success] = message
      else
        flash[:error] = message
      end
    end

  end

  def add_mobile
    if request.method == 'POST'
      current_user.mobile = params[:user][:mobile]
      current_user.mobile_code = params[:user][:mobile_code]
      if params[:user][:mobile].present?
        status, message = self.add_mobile_validate(current_user, params[:user][:mobile], params[:user][:mobile_code])
        if status
          flash[:success]= message
        else
          flash[:error] = message
        end
      else
        flash[:error] = '手机号不能为空'
      end

    end

  end

  def add_mobile_validate(current_user, mobile, mobile_code)
    unless current_user.present?
      return [FALSE, '原用户不存在，请重新登录']
    end
    user = User.find_by_mobile(mobile)
    unless user.blank?
      return [FALSE, '该手机号已经被使用']
    end
    status, message = SMSService.new(mobile).validate?(mobile_code, SMSService::TYPE_CODE_ADD_MOBILE)
    unless status
      return [FALSE, message]
    end
    if status
      current_user.mobile = mobile
      if current_user.save
        [TRUE, '手机号已成功添加']
      end

    else
      [FALSE, '添加手机号过程出错']
    end

  end

  # 修改手机号方法
  def change_mobile(old_username, new_username, password, mobile_code)
    user = User.find_by_mobile(old_username)
    unless user.present?
      return [FALSE, '原用户不存在，请重新登录']
    end
    unless password.present?
      return [FALSE, '密码不能为空']
    end

    unless user.valid_password?(password)
      return [FALSE, '密码不正确']
    end

    unless new_username.present?
      return [FALSE, '新手机号不能为空']
    end

    unless Regular.is_mobile?(new_username)
      return [FALSE, '新手机号格式错误']
    end

    unless mobile_code.present?
      return [FALSE, '验证码不能为空']
    end
    status, message = SMSService.new(new_username).validate?(mobile_code, SMSService::TYPE_CODE_RESET_MOBILE)

    unless status
      return [FALSE, message]
    end
    if user.valid_password?(password)
      user.mobile = new_username
      if user.save
        [TRUE, '手机号已成功修改，请重新登录。']
      else
        [FALSE, '手机号修改过程出错']
      end
    end
  end

  def notification
    @notifications = Notification.where(user_id: current_user.id)
  end


end
