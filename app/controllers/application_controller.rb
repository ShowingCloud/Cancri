class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
    cookies.signed[:user_id] ||= current_user.try(:id)
  end


  before_action :configure_permitted_parameters, if: :devise_controller?


  def render_404
    render_optional_error_file(404)
  end

  def render_403
    render_optional_error_file(403)
  end

  def render_optional_error_file(status_code)
    status = status_code.to_s
    fname = %w(404 403 422 500).include?(status) ? status : 'unknown'
    render template: "/errors/#{fname}", format: [:html],
           handler: [:erb], status: status, layout: 'application'
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  # def redirect_back_or_default(default)
  #   redirect_to(session[:return_to] || default)
  #   session[:return_to] = nil
  # end

  # def redirect_referrer_or_default(default)
  #   redirect_to(request.referrer || default)
  # end

  def require_user
    if current_user.blank?
      respond_to do |format|
        format.html { authenticate_user! }
        format.all { head(:unauthorized) }
      end
    end
  end

  def require_email
    if current_user.present?
      current_user.email.present?
    else
      require_user
    end
  end

  def require_mobile
    if current_user.present?
      current_user.mobile.present?
    else
      require_user
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:nickname, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.permit(:sign_in) { |u| u.permit(:login, :password, :remember_me) }
    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password) }
  end


end
