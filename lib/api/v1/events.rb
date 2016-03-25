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
      end
    end
  end
end