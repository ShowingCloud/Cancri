module Api
  module V1
    class EventsController < Api::V1::ApplicationController
      # before_action :authenticate!

      # 获取某一项目的成绩属性
      # GET /api/v1/events/score_attrs

      def score_attrs
        requires! :event_id
        esa = CompetitionService.get_event_score_attrs(params[:event_id])
        render json: esa
      end

    end
  end
end