class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def cas
    @user = User.from_sso(request.env["omniauth.auth"])
    sign_in_and_redirect @user, :event => :authentication
    set_flash_message(:notice, :success, :kind => "SSO") if is_navigational_format?
  end

  def failure
    redirect_to root_path
  end
end
