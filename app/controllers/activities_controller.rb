class ActivitiesController < ApplicationController
  before_action :authenticate_user!, :only => [:apply_activity, :apply_require]

  def index
    @activities = Activity.where(status: 1).order('id desc').page(params[:page]).per(params[:per])
  end

  def show
    @activity = Activity.find(params[:id])
    if current_user.present?
      @already_apply = ActivityUserShip.where(user_id: current_user.id, activity_id: params[:id]).exists?
      unless @already_apply
        user_info = UserProfile.left_joins(:school, :district, :user).where(user_id: current_user.id).select(:username, :grade, :birthday, :school_id, :district_id, :bj, 'users.mobile', 'schools.name as school_name', 'districts.name as district_name').take; false
        @user_info = user_info ||= current_user.build_user_profile
      end
    end
  end

  def apply_require
    unless require_mobile
      flash[:notice]='您还没有验证手机，请到个人中心验证'
    end
    redirect_to '/activities/'+params[:id]
  end

  def apply_activity
    if require_mobile
      act_id = params[:act_d]
      username = params[:username]
      school_id = params[:school]
      district_id = params[:district]
      birthday = params[:birthday]
      grade = params[:grade]

      if act_id.present? && username.present? && school_id.present? && birthday.present? && grade.to_i !=0 && district_id.present?
        activity = Activity.find_by_id(act_id)
        if activity.present? && (activity.apply_end_time > Time.now)
          user_profile = current_user.user_profile ||= current_user.build_user_profile
          if user_profile.update_attributes(username: username, school_id: school_id, district_id: district_id, birthday: birthday, grade: grade)
            user_id = current_user.id
            has_apply = ActivityUserShip.where(activity_id: act_id, user_id: user_id).exists?
            if has_apply
              result=[false, '您已经报名']
            else
              u_c = ActivityUserShip.create(activity_id: act_id, user_id: user_id, school_id: school_id, grade: grade)
              if u_c.save
                result=[true, '报名成功']
              else
                result=[false, '报名失败']
              end
            end
          else
            result = [false, '信息填写不规范']
          end
        else
          result = [false, '不规范操作或已过报名时间']
        end
      else
        result=[false, '信息填写不规范或不完整']
      end
    else
      result=[false, '您还没有验证手机，请到个人中心验证']
    end
    render json: result
  end
end
