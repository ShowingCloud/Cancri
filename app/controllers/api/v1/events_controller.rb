module Api
  module V1
    class EventsController < Api::V1::ApplicationController
      before_action :authenticate!

      # 获取某一项目的成绩属性
      # GET /api/v1/events/score_attrs

      def score_attrs
        requires! :event_id, type: Integer
        requires! :schedule_id, type: Integer
        esa = CompetitionService.get_event_score_attrs(params[:event_id],params[:schedule_id])
        render json: esa
      end

      # 获取某一项目指定分组的赛程
      # GET /api/v1/events/group_schedules

      def group_schedules
        requires! :event_id, type: Integer
        requires! :group, type: Integer, values: 1..4
        es = EventSchedule.joins(:schedule).where(event_id: params[:event_id], group: params[:group], is_show: true).select(:id, :schedule_id, :sort, :kind, 'schedules.name as schedule_name').order('sort asc')
        render json: {group_schedules: es}
      end

      # 获取特定项目下某分组指定赛程的队伍
      # GET /api/v1/events/group_teams

      def group_teams
        requires! :event_id, type: Integer
        requires! :group, type: Integer, values: 1..4
        requires! :schedule_id, type: Integer
        optional! :has_score, values: %w(0 1) # 未参加 已参加
        teams = CompetitionService.get_group_teams(params[:event_id], params[:group], params[:schedule_id], params[:has_score])
        render json: teams
      end

      # 根据队伍编号获取队伍及队员信息
      # GET /api/v1/events/get_team_by_identifier

      def get_team_by_identifier
        requires! :identifier, type: String, desc: '队伍编号'
        team_info = CompetitionService.via_identifier_get_team(params[:identifier])
        render json: team_info
      end

    end
  end
end