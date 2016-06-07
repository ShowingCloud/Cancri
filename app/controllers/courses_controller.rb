class CoursesController < ApplicationController
  before_action :require_user, only: [:apply]

  def index
    @courses = Course.where(status: 1).select(:id, :name).page(params[:page]).per(params[:per])
  end

  def show
    @course = Course.find(params[:id])
    @has_apply = CourseUserShip.where(user_id: current_user.id, course_id: params[:id]).exists?
  end

  def apply
    cd = params[:cd]
    has_apply= CourseUserShip.where(user_id: current_user.id, course_id: cd).exists?
    if has_apply
      result=[false, '您已经报名该比赛']
    else
      c_u = CourseUserShip.create!(user_id: current_user.id, course_id: cd)
      if c_u.save
        result = [true, '报名成功']
      else
        result = [false, '报名失败']
      end
    end
    flash[:notice] = result[1]
    redirect_to "/courses/#{params[:cd]}"
  end
end

