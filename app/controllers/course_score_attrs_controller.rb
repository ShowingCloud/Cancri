class CourseScoreAttrsController < ApplicationController
  before_action :authenticate_user!, :is_teacher

  def new
    @course_score_attr = CourseScoreAttribute.new
  end

  def create
    course = Course.find(csa_params[:course_id])
    if course.user_id == current_user.id
      @course_score_attr = CourseScoreAttribute.new(csa_params)
      respond_to do |format|
        if @course_score_attr.save
          format.html { redirect_to course_score_attrs_path, notice: '属性新增成功。' }
          format.js
        else
          @course_score_attr.course_id = csa_params[:course_id]
          format.html { render :new }
          format.js
        end
      end
    else
      render_optional_error(403)
    end
  end


  private

  def csa_params
    params.require(:course_score_attribute).permit!
  end
end