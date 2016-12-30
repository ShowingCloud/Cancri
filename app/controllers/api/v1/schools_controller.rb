module Api
  module V1
    class SchoolsController < Api::V1::ApplicationController

      # 获取特定区县学校列表
      # GET /api/v1/schools/get_by_district

      def get_by_district
        requires! :district_id
        schools = School.where(status: 1, district_id: params[:district_id]).select(:id, :name).order(:name)
        render json: schools
      end

    end
  end
end
