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
          @users = User.all.limit(params[:limit])
          render @users
        end
        ## test login
        post 'login' do
          @user = User.find_by_email(params[:session][:email].downcase)
          if @user && @user[:locked]
            error!({"error" => "该账户已锁定，请先解锁。"}, 400)
          elsif @user && !@user[:locked] && @user.authenticate(params[:session][:password]) # && @user[:last_login].nil?
            sign_in @user
          elsif @user && !@user[:locked] && @user.authenticate(params[:session][:password]) # && !@user[:last_login].nil?
            @user.update_attributes(:failed_attempts => 0, :last_login => Time.now)
            sign_in @user
          else
            error!({"error" => "账户或者密码错误。"}, 400)
          end
        end
      end
    end
  end
end
