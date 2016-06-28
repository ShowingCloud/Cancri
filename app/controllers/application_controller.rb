class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :has_teacher_role, :is_teacher

  before_action :configure_permitted_parameters, if: :devise_controller?

  def require_user
    if current_user.blank?
      respond_to do |format|
        format.html { authenticate_user! }
        format.all { head(:unauthorized) }
      end
    end
  end

  def require_mobile
    if current_user.present?
      current_user.mobile.present?
    else
      require_user
    end
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render_optional_error(404)
  end

  def render_optional_error(status_code)
    status = status_code.to_s
    fname = %w(404 403 422 500).include?(status) ? status : 'unknown'
    render template: "/errors/#{fname}", format: [:html],
           handler: [:erb], status: status, layout: request.fullpath.to_s.index('/admin') ? 'admin_boot' : 'application'
  end

  def has_teacher_role
    return false if current_user.blank?
    @has_th_role ||= UserRole.where(user_id: current_user.id, role_id: 1, status: 1).exists?
  end

  def is_teacher
    if has_teacher_role
    else
      render_optional_error(403)
    end
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:nickname, :email, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.permit(:sign_in) { |u| u.permit(:login, :password, :remember_me, :return_to) }
    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password) }
  end
end
