module API
  module V1
    class Competitions < Grape::API
      resource :competitions do
        # Get all competition
        params do
          optional :limit, type: Integer, default: 20, values: 1..150
        end

        get do
          params[:limit] = 100 if params[:limit] > 100
          @competitions = CompetitionService.get_competitions
          render @competitions
        end

      end
    end
  end
end
