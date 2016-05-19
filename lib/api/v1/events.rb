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

        desc '获取某项目特定分组的赛程'
        params do
          requires :ed, type: Integer, desc: '项目ID'
          requires :group, type: Integer, desc: '组别'
        end
        get '/event_schedule' do
          es = EventSchedule.joins(:schedule).where(event_id: params[:ed], group: params[:group]).select(:id, :schedule_id, :kind, 'schedules.name').order('schedule_id asc').map { |s| {
              id: s.id,
              schedule_name: s.name,
              schedule_id: s.schedule_id,
              kind: s.kind
          } }
          render event_schedules: es
        end

        desc '获取特定项目下某分组指定赛程的队伍'
        params do
          requires :ed, type: Integer
          requires :group, type: Integer
          requires :schedule_id, type: Integer
        end
        get '/event/teams' do
          teams = CompetitionService.get_teams(params[:ed], params[:group], params[:schedule_id])
          render teams: teams
        end
      end
    end
  end
end