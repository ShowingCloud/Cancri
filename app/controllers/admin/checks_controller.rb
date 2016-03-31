class Admin::ChecksController < AdminController

  before_action do
    authenticate_permissions(['admin'])
  end

  def teachers
    @teachers = UserProfile.joins(:user_roles).where('user_roles.role_id=?', 1).where('user_roles.status is NULL').select(:id, :user_id, :username, :certificate, :school, :teacher_no).map { |c| {
        id: c.id,
        user_id: c.user_id,
        school: c.school,
        num: c.teacher_no,
        username: c.username,
        certificate: c.certificate.present? ? ActionController::Base.helpers.asset_path(c.certificate_url(:large)) : nil
    } }
  end

  def review_teacher
    level = params[:level]
    ud = params[:ud]
    status = params[:status]
    if status.present?
      ur = UserRole.where(user_id: ud, role_id: 1).take
      if ur.present?
        ur.status = true
        ur.role_type = level
        if ur.save
          result = [true, '操作成功']
        else
          result = [false, '操作失败']
        end
      else
        result = [false, '该教师角色不存在']
      end
    else
      result = [false, '请选择审核结果']
    end
    render json: result
  end

  def referees

  end

end

