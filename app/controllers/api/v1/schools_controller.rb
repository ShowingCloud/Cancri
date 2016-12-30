module Api
  module V1
    class SchoolsController < Api::V1::ApplicationController
      before_action :authenticate_admin, only: [:create]

      # 获取特定区县学校列表
      # GET /api/v1/schools/get_by_district

      def get_by_district
        requires! :district_id
        schools = School.where(status: 1, district_id: params[:district_id]).select(:id, :name).order(:name)
        render json: schools
      end

      # 添加学校
      # POST /api/v1/schools

      def create
        requires! :name
        requires! :district_id, type: Integer
        school = School.create(name: params[:name], district_id: params[:district_id], status: true)
        if school.save
          result = [true, '学校添加成功', school.id]
        else
          result = [false, school.errors.full_messages.first]
        end
        render json: {status: result[0], message: result[1], school_id: result[2]}
      end
    end
  end
end
