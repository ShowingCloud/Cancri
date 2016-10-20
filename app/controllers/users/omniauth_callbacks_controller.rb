class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def cas
    @user = User.from_sso(request.env["omniauth.auth"])
    if params[:auth_type] === "token"
      sign_in @user, :event => :authentication
      token = SecureRandom.uuid.gsub('-', '')
      $redis.set "token-#{token}",{id:@user.id,auth_at:Time.zone.now}.to_json
      render json:{token: token}
    else
      sign_in_and_redirect @user, :event => :authentication
      set_flash_message(:notice, :success, :kind => "SSO") if is_navigational_format?
    end
  end

  def failure
    redirect_to root_path
  end
end
