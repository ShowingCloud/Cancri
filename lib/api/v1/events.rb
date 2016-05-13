module API
  module V1
    class Events < Grape::API
      resources :events do
        desc '获取比赛项目成绩属性'
        params do
          requires :event_id, type: Integer, desc: '比赛项目ID'
        end
        get '/score_attributes' do
          ess = CompetitionService.get_event_score_attrs(params[:event_id])
          render event_score_attributes: ess
        end

        desc '获取某项目的赛程'
        params do
          requires :ed, type: Integer, desc: '项目ID'
        end
        get '/schedule' do
          es = EventSchedule.joins(:schedule).where(event_id: params[:ed]).select(:id, :schedule_id, :kind, 'schedules.name').map { |s| {
              id: s.id,
              schedule_name: s.name,
              schedule_id: s.schedule_id,
              kind: s.kind
          } }
          render event_schedules: es
        end
      end
    end
  end
end