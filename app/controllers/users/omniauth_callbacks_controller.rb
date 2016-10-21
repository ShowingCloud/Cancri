class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def cas
    @user = User.from_sso(request.env["omniauth.auth"])
    if params[:auth_type] === "token"
      sign_in @user, :event => :authentication
      token = SecureRandom.uuid.gsub('-', '')
      $redis.set "token-#{token}",{id:@user.id,auth_at:Time.zone.now}.to_json
      $redis.set("ticket-#{params[:ticket]}",{session_id:session.id,token:token}.to_json)
      render json:{token: token}
    else
      sign_in_and_redirect @user, :event => :authentication
      $redis.set("ticket-#{params[:ticket]}",{session_id:session.id}.to_json)
    end
  end

  def failure
    redirect_to root_path
  end
end
