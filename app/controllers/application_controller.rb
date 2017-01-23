class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :has_teacher_role, :is_teacher, :check_teacher_role, :show_teacher_role

  before_action :configure_permitted_parameters, if: :devise_controller?

  before_action do
    cookies.signed[:user_id] ||= current_user.try(:id)
  end

  def new_session_path(scope)
    new_user_session_path
  end

  def session_path(scope)
    new_user_session_path
  end

  def after_sign_in_path_for(resource)
    request.env['omniauth.origin'] || stored_location_for(resource) || root_path
  end

  def current_user
    return @current_user if defined? @current_user
    @current_user ||= warden.authenticate(scope: :user)
  end

  def require_mobile
    if current_user.present?
      response = Typhoeus.get("#{Settings.auth_url}/user_infos/#{current_user.id}.json", headers: {Authorization: Settings.auth_token})
      if response.code == 200
        data = JSON.parse(response.body)
        return true && current_user.update_attributes(mobile: data["mobile"]) if data["mobile"].present?
      else
        logger.error "request user data from #{response.effective_url} failed"
        current_user.mobile.present?
      end
    else
      false
    end
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render_optional_error(404)
  end

  def render_optional_error(status_code)
    status = status_code.to_s
    fname = %w(404 403 422 500).include?(status) ? status : 'unknown'
    render template: "/errors/#{fname}", formats: [:html],
           handler: [:erb], status: status, layout: request.fullpath.to_s.index('/admin') ? 'admin_boot' : 'application'
  end

  def check_teacher_role(ud)
    if ud.to_i !=0
      UserRole.where(role_id: 1, user_id: ud, status: 1).exists?
    else
      false
    end
  end

  def has_teacher_role
    return false if current_user.blank?
    @has_th_role ||= UserRole.where(user_id: current_user.id, role_id: 1, status: 1).exists?
  end

  def is_teacher
    unless has_teacher_role
      render_optional_error(403)
    end
  end

  def super_district_teacher
    return false if current_user.blank?
    @district_teacher_role = current_user.user_roles.where(role_id: 1, role_type: 2, status: 1).take
    unless @district_teacher_role.present?
      render_optional_error(403)
    end
  end

  def the_course_teacher(course_id)
    if Course.find_by_id(course_id).user_id == current_user.id
      true
    else
      render_optional_error(403)
    end
  end

  def show_teacher_role(role_type)
    case role_type when 1
                     '市级'
      when 2
        '区级（高级）'
      when 3
        '校级（高级）'
      when 4
        '区级'
      when 5
        '校级'
      when 6
        '外聘'
      else
        '未知'
    end
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:nickname, :email, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.permit(:sign_in) { |u| u.permit(:login, :password, :remember_me, :return_to) }
    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password) }
  end
end
