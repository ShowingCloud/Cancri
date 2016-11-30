module Api
  module V1
    class CompetitionsController < Api::V1::ApplicationController
      # before_action :authenticate!

      # 获取比赛列表
      # GET /api/v1/competitions

      def index
        @competitions = Competition.includes(:competition_schedules).where(status: 1).select(:id, :name, :emc_contact)
        render json: @competitions, :include => :competition_schedules, only: [:id, :name, :emc_contact]
      end

      # 获取特定比赛下项目列表
      # GET /api/v1/get_events

      def get_events
        requires! :comp_id, type: Integer
        @events = CompetitionService.get_events(params[:comp_id])
        render json: @events
      end

      # 获取特定比赛下分组
      # GET /api/v1/get_events

      def get_parent_group
        requires! :comp_id
        comp_groups = Event.joins(:competition).where(competition_id: params[:comp_id], is_father: true).select(:id, :name, 'competitions.name as comp_name')
        render json: comp_groups
      end

    end
  end
end