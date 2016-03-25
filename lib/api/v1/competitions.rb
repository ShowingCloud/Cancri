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
