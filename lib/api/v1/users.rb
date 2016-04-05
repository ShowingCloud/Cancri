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

          desc '根据队伍'
          params do
            requires :identifier, type: String, desc: '队伍编号'
          end
          get '/team_players' do
            team = Team.joins(:event).joins('INNER JOIN competitions ON competitions.id = events.competition_id').where(identifier: '12345').select(:name, :id, 'events.name as event_name', 'events.competition_id as comp_id', 'competitions.name as comp_name').take
            aa = TeamUserShip.joins('INNER JOIN user_profiles ON user_profiles.user_id = team_user_ships.user_id').where(team_id: 1).select('user_profiles.username', 'user_profiles.school', 'user_profiles.grade', 'user_profiles.gender')
            render team_name: team.name, event_name: team.event_name, comp_name: team.comp_name, user: aa
          end
        end

      end
    end
  end
end
