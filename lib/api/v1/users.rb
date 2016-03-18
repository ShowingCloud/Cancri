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

        params do
          requires :private_token, type: String, desc: 'Private Token'
        end

        namespace ':private_token' do
          before do
            authenticate!
          end

          desc '获取用户信息'
          get '/' do
            render user: current_user
          end

          desc '获取用户未读消息数量'
          get '/notifications/unread' do
            @unread_notify =current_user.notifications.unread.count
            render @unread_notify
          end

        end

      end
    end
  end
end
