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


      # 报名课程的用户批量删除自己的作品
      # POST /api/v1/users/delete_course_opus

      def delete_course_opus
        cp_ids = params[:course_opus_ids]
        if cp_ids.present? && cp_ids.is_a?(Array)
          user_ids = CourseOpu.joins(:course_user_ship).where(id: params[:cp_ids]).pluck('course_user_ships.user_id')
          if user_ids.present? && user_ids.uniq == [current_user.id] && user_ids.length == cp_ids.length
            if CourseOpu.delete(cp_ids)
              result= [true, '删除成功']
            else
              result= [false, '删除失败']
            end
          else
            result = [false, '不规范请求']
          end
        else
          result = [false, '参数不规范']
        end
        render json: {status: result[0], message: result[1]}
      end

      # 报名课程的用户更新自己作品
      # POST /api/v1/users/update_course_opus

      def update_course_opus
        requires! :id, type: Integer
        requires! :desc
        requires! :name
        course_opus_id = params[:id]
        desc = params[:desc]
        name = params[:name]
        current_user_id = current_user.id
        course_opus = CourseOpu.joins(:course_user_ship).where(id: course_opus_id).select('course_opus.*', 'course_user_ships.user_id').take
        if course_opus.present? && course_opus.user_id == current_user_id
          course_opus.desc = desc
          course_opus.name = name
          if course_opus.save
            result = [true, '更新成功']
          else
            result = [false, '更新失败']
          end
        else
          result = [false, '不规范请求']
        end
        render json: {status: result[0], message: result[1]}
      end


    end
  end
end
