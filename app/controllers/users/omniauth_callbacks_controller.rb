class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def cas
    @user = User.from_sso(request.env["omniauth.auth"])
    if params[:auth_type] === "token"
      sign_in @user, :event => :authentication
      session[:ticket] = params[:ticket]
      session.options[:id] = session.instance_variable_get(:@by).generate_sid
      session.options[:renew] = false
      token = SecureRandom.uuid.gsub('-', '')
      $redis.set "token-#{token}",{id:@user.id,auth_at:Time.zone.now}.to_json
      $redis.set("ticket-#{params[:ticket]}",{session_id:session.id,token:token}.to_json)
      render json:{token: token}
    else
      puts session.id
      sign_in_and_redirect @user, :event => :authentication
      session[:ticket] = params[:ticket]
      session.options[:id] = session.instance_variable_get(:@by).generate_sid
      session.options[:renew] = false
      puts session.id
      $redis.set("ticket-#{params[:ticket]}",{session_id:session.id}.to_json)
    end
  end

  def failure
    redirect_to root_path
  end
end
