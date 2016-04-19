class ActivitiesController < ApplicationController
  before_action :authenticate_user!, :only => [:apply_activity]

  def index
    @activities = Activity.all.page(params[:page]).per(params[:per])
  end

  def show
    @activity = Activity.find(params[:id])
  end

  def apply_activity
    username = params[:username]
    school = params[:school].to_i
    age= params[:age].to_i
    grade = params[:grade]
    if /\A[\u4e00-\u9fa5]{2,4}\Z/.match(username)==nil
      result = [false, '姓名为2-4位中文']
    else
      if username.present? && school !=0 && age != 0 && grade.present? && UserProfile.update_attributes!(username: username, school: school, age: age, grade: grade)
        if params[:act_id].present?
          cw = UserActivityShip.where(activity_id: params[:act_id], user_id: current_user.id).exists?
          if cw
            result=[false, '您已经报名']
          else
            u_c = UserActivityShip.create!(activity_id: params[:act_id], user_id: current_user.id)
            if u_c.save
              result=[true, '报名成功']
            else
              result=[false, '报名失败']
            end
          end
        else
          result=[false, '参数不完整']
        end
      else
        result=[false, '个人信息填写不规范']
      end
    end
    render json: result
  end
end
