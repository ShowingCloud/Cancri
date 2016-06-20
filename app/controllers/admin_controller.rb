class AdminController < ActionController::Base
  before_action :set_current_admin, :authenticate

  def index
    @all_user_num = User.count
    @review_th_num = UserRole.where(role_id: 1, status: 0).count
    @review_fh_num = UserRole.where(role_id: 2, status: 0).count
    # @review_re_num = CompWorker.where('status is NULL').count
    @review_sc_num = School.where(user_add: 1).where('audit is NULL').count
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render_optional_error(404)
  end

  def render_optional_error(status_code)
    status = status_code.to_s
    fname = %w(404 403 422 500).include?(status) ? status : 'unknown'
    render template: "/errors/#{fname}", format: [:html],
           handler: [:erb], status: status, layout: 'admin_boot'
  end

  protected

  def set_current_admin
    begin
      @current_admin ||= Admin.authenticated_access_token(cookies[:access_token])
    rescue ActiveRecord::RecordNotFound
      nil
    end
  end

  def authenticate
    unless @current_admin.present?
      redirect_to controller: 'admin/accounts', action: 'new'
    end
  end

  def authenticate_permissions(permissions)
    authenticate
    unless @current_admin.auth_permissions(permissions)
      render text: '没有权限'
    end
    FALSE
  end

end
