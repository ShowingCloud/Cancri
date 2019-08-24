class DownloadsController < ApplicationController
  before_action :authenticate_user!

  def index
    if UserRole.where(user_id: current_user, role_id: 1, status: true).exists?
      @has_role = true
    else
      @has_role = false
    end
  end
end