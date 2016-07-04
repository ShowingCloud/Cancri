class CoursesController < ApplicationController
  before_action :authenticate_user!, only: [:apply, :apply_show]

  def index
    course=Course.where(status: 1)
    if cookies[:area]
      course = course.where(district_id: 9)
    end
    @course_array = course.select(:id, :name, :num, :apply_count, :apply_end_time).page(params[:page]).per(params[:per])
    if current_user.present?
      @courses = @course_array.map { |c| {
          id: c.id,
          name: c.name,
          num: c.num,
          apply_end_time: c.apply_end_time,
          apply_count: c.apply_count,
          has_apply: c.course_user_ships.where(user_id: current_user.id).exists?
      } }
    else
      @courses = @course_array.map { |c| {
          id: c.id,
          name: c.name,
          num: c.num,
          apply_end_time: c.apply_end_time,
          apply_count: c.apply_count,
          has_apply: false
      } }
    end

  end

  def show
    course = Course.find(params[:id])
    if cookies[:area] && course.district_id !=9
      render_optional_error(404)
    end
    if current_user.present?
      @has_apply = CourseUserShip.where(user_id: current_user.id, course_id: params[:id]).exists?
    end
    @course = course
    if current_user.present?
      user_info = UserProfile.where(user_id: current_user.id).left_joins(:school, :district).select(:grade, :username, :district_id, :school_id, 'districts.name as district_name', 'schools.name as school_name')
      if user_info.present?
        user_info = user_info.to_a.first
      else
        user_info = current_user.build_user_profile
      end
      @user_info = user_info
    end
  end

  def apply_show
    if current_user.present?
      user_info = UserProfile.where(user_id: current_user.id).left_joins(:school, :district).select(:grade, :username, :district_id, :school_id, 'districts.name as district_name', 'schools.name as school_name')
      if user_info.present?
        user_info = user_info.to_a.first
      else
        user_info = current_user.build_user_profile
      end
      @user_info = user_info
    end
  end

  def apply
    if request.method =='POST'
      username = params[:username]
      district_id = params[:district]
      school_id = params[:school]
      grade = params[:grade]
      cds = params[:cds].to_unsafe_h
      message = ''
      if username.present? && district_id.present? && school_id.present? && grade.present? && cds.present? && cds.is_a?(Hash)
        if require_mobile
          if cds.length < 4
            u_r = UserProfile.where(user_id: current_user.id).take
            if u_r.present?
              u_r.update_attributes(username: username, grade: grade, district_id: district_id, school_id: school_id)
            else
              UserProfile.create!(user_id: current_user.id, username: username, grade: grade, district_id: district_id, school_id: school_id)
            end
            cds.each do |cd|
              has_apply= CourseUserShip.where(user_id: current_user.id, course_id: cd[0]).exists?
              if has_apply
                message += cd[1].to_s+':已经报名过，无需再次报名;'
              else
                c_u = CourseUserShip.create!(user_id: current_user.id, course_id: cd[0], school_id: school_id, grade: grade)
                if c_u.save
                  message += cd[1].to_s+':报名成功;'
                else
                  message += cd[1].to_s+':报名失败;'
                end
              end
            end
            result = [true, message]
          else
            result = [false, '一次操作最多选择三个课程']
          end
        else
          result = [false, '请先在个人中心添加手机']
        end
      else
        result = [false, '信息不完整']
      end
    else
      result = [false, '不规范请求']
    end
    render json: result
  end
end

