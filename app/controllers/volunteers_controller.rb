class VolunteersController < ApplicationController
  before_action :authenticate_user!, except: [:recruit]

  def index
    @user_info = User.left_joins(:user_profile).where(id: current_user.id).select(:id, :mobile, 'user_profiles.username', 'user_profiles.gender', 'user_profiles.grade', 'user_profiles.standby_school', 'user_profiles.identity_card', 'user_profiles.alipay_account').take
    volunteer_role = current_user.user_roles.where(role_id: 3).take
    @has_apply = volunteer_role.present? ? volunteer_role.status : false #[false,0,1,2]
  end


  def apply_volunteer
    user_params = params[:user]
    standby_school = user_params[:standby_school]
    gender = user_params[:gender]
    grade = user_params[:grade]
    identity_card = user_params[:identity_card]
    alipay_account = user_params[:alipay_account]
    if require_mobile
      if standby_school.present? && gender.present? && grade.present? && identity_card.present? && alipay_account.present?
        user_profile = current_user.user_profile ||= current_user.build_user_profile
        if user_profile.update_attributes(gender: gender, grade: grade, standby_school: standby_school, identity_card: identity_card, alipay_account: alipay_account)
          volunteer_role = UserRole.create(user_id: current_user.id, role_id: 3, status: 0, role_type: 1)
          if volunteer_role.save
            result = [true, '申请成功，请等待审核，结果将通过消息推送告知您']
          else
            result = [false, '申请失败']
          end
        else
          result = [false, user_profile.errors.full_messages.first]
        end
      else
        result = [false, '请将参数填写完整']
      end
    else
      result = [false, '请先验证手机']
    end

    respond_to do |format|
      if result[0]
        format.html { redirect_to volunteers_path, notice: result[1] }
      else
        @user_info = UserProfile.new(params[:user].permit(:grade, :gender, :standby_school, :identity_card, :alipay_account))
        flash.now[:alert] = result[1]
        format.html { render action: 'index' }
      end
      format.js { render json: {status: result[0], message: result[1]} }
    end
  end


  def cancel_apply
    has_apply = current_user.user_roles.where(role_id: 3).take
    if has_apply.present? && has_apply.status == 0 && has_apply.delete
      result = [true, '取消成功']
    else
      result = [false, '取消失败']
    end
    flash[:notice] = result[1]
    redirect_to volunteers_path
  end

  def apply_event_volunteer
    event_volunteer_id = params[:event_volunteer_id]
    volunteer_role = current_user.user_roles.where(role_id: 3, status: 1).take
    if volunteer_role.present?
      if volunteer_role.status == 1
        if current_user.event_volunteer_users.create(event_volunteer_id: event_volunteer_id, status: 0)
          result = [true, '申请成功,审核结果将消息推送告知您']
        else
          result = [false, '申请失败']
        end
      elsif volunteer_role.status == 0
        result = [false, '您的志愿者身份还未审核通过，暂不能报名']
      else
        result = [false, '申请状态错误']
      end
    else
      result = [false, '您目前没有志愿者身份，请先认证志愿者身份']
    end

    respond_to do |format|
      format.html { redirect_to "/volunteers/recruit/#{event_volunteer_id}", notice: result[1] }
      format.json { render json: {status: result[0], message: result[1]} }
    end
  end

  def recruit
    event_volunteer_id = params[:id]
    if event_volunteer_id.present?
      @event_volunteer = EventVolunteer.find(event_volunteer_id)
      if current_user.present?
        @has_apply = current_user.event_volunteer_users.where(event_volunteer_id: event_volunteer_id).select(:status).take
      end
    else
      @event_volunteers = EventVolunteer.where(status: 1)
    end
  end

  def points
  end
end
