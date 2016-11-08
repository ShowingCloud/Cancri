module Api
  module V1
    class CompetitionsController < Api::V1::ApplicationController
      # before_action :authenticate!

      # 获取比赛列表
      # GET /api/v1/competitions

      def index
        @competitions = Competition.includes(:competition_schedules).where(status: 1).select(:id, :name)
        render json: @competitions, :include => :competition_schedules, only: [:id, :name]
      end

      # 获取特定比赛下项目列表
      # GET /api/v1/get_events

      def get_events
        requires! :comp_id, type: Integer
        @events = CompetitionService.get_events(params[:comp_id])
        render json: @events
      end

    end
  end
end