class AdminController < ActionController::Base
  before_action :set_current_admin, :authenticate

  def index
    @all_user_num = User.count
    @review_th_num = UserRole.where(role_id: 1).where('status is NULL').count
    @review_re_num = CompWorker.where('status is NULL').count
    @review_sc_num = School.where(user_add: true).count
  end

  protected

  def set_current_admin
    begin
      # access_token 验证模式
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
