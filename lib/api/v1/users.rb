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

          params do
            requires :identifier, type: String, desc: '队伍编号'
          end
          get '/team_players' do
            users = TeamUserShip.joins(:team).where("teams.identifier=?", params[:identifier]).where("team_user_ships.team_id=teams.id").pluck(:user_id)
            @user_info = UserProfile.where(user_id: users).map { |x| {
                username: x.try(:username),
                school: x.try(:school),
                grade: x.try(:grade).to_i
            } }
            render user: @user_info
          end


        end

      end
    end
  end
end
