module API
  module V1
    class Competitions < Grape::API
      resource :competitions do
        # Get all competition
        params do
          optional :limit, type: Integer, default: 20, values: 1..150
        end
        desc '获取大赛列表'
        get do
          params[:limit] = 100 if params[:limit] > 100
          @competitions = CompetitionService.get_competitions
          render @competitions
        end

        desc '获取某大赛下比赛项目'
        params do
          requires :comp_id, type: Integer
        end
        get '/events' do
          @events = CompetitionService.get_events(params[:comp_id])
          render events: @events
        end

        desc '获取特定项目下某分组队伍'
        params do
          requires :ed, type: Integer
          requires :group, type: Integer
          optional :schedule_id, type: Integer
        end
        get '/event/teams' do
          teams = CompetitionService.get_teams(params[:ed], params[:group], params[:schedule_id])
          render teams: teams
        end


        # params do
        #   requires :private_token, type: String, desc: 'Private Token'
        # end
        #
        # namespace ':private_token' do
        #   before do
        #     authenticate!
        #   end
        #   # Get all competition
        #   params do
        #     optional :limit, type: Integer, default: 20, values: 1..150
        #   end
        #
        #   get do
        #     params[:limit] = 100 if params[:limit] > 100
        #     @competitions = CompetitionService.get_competitions
        #     render @competitions
        #   end
        #
        # end
      end
    end
  end
end
