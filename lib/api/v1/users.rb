module API
  module V1
    class Users < Grape::API
      resource :users do
        # Get 20 users
        params do
          optional :limit, type: Integer, default: 20, values: 1..150
        end
        get do
          params[:limit] = 100 if params[:limit] > 100
          @users = User.all
          render @users
        end

      end
    end
  end
end
