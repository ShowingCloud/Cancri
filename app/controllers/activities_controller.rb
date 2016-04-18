class ActivitiesController < ApplicationController
  before_action :authenticate_user!, :only => [:apply_activity]

  def index
    @activities = Activity.all.page(params[:page]).per(params[:per])
  end

  def show
    @activity = Activity.find(params[:id])
  end

  def apply_activity
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
    render json: result
  end
end
