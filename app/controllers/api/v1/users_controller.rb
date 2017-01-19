module Api
  module V1
    class UsersController < Api::V1::ApplicationController
      before_action :authenticate!
      # before_action :set_user, except: [:index]

      ##
      # 获取用户
      #
      # GET /api/v1/users
      #
      # def index
      #   @users = User.all.limit(20)
      #   render json: @users
      # end

      # 报名课程的用户上传作品
      # POST /api/v1/users/upload_course_opus

      def upload_course_opus
        course_opu = params[:course_opu]
        course_id = course_opu[:course_id]
        course_user_ship_id = course_opu[:course_user_ship_id]
        name = course_opu[:name]
        desc = course_opu[:desc]
        cover = course_opu[:cover]

        has_apply = CourseUserShip.joins(:course).where(course_id: course_id, user_id: current_user.id).select(:id, :course_id, 'courses.start_time', 'courses.end_time').take
        time_now = Time.zone.now
        if has_apply.present? && (time_now > has_apply.start_time) && (time_now < has_apply.end_time)
          course_opus = CourseOpu.create(course_user_ship_id: course_user_ship_id, name: name, desc: desc, cover: cover)
          if course_opus.save
            result = [true, '上传成功']
          else
            result = [false, course_opus.errors.full_messages.first]
          end
        else
          result = [false, '您没有报名该课程，或不在上传时间']
        end
        render json: {status: result[0], message: result[1]}
      end


      private

      def set_user
        @user = User.find_by_nickname(params[:id])
      end
    end
  end
end
