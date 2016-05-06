class Admin::ChecksController < AdminController

  before_action do
    authenticate_permissions(['admin'])
  end

  def teachers
    @teachers = UserProfile.joins(:user_roles).joins('inner join schools s on user_profiles.school=s.id').where('user_roles.role_id=?', 1).where('user_roles.status is false').select(:id, :user_id, :username, :gender, :certificate, 's.name as school_name', :mobile, :teacher_no).page(params[:page]).per(params[:per])
    @teacher_array = @teachers.map { |c| {
        id: c.id,
        user_id: c.user_id,
        school: c.school_name,
        mobile: c.mobile,
        num: c.teacher_no,
        username: c.username,
        gender: c.gender,
        certificate: c.certificate.present? ? ActionController::Base.helpers.asset_path(c.certificate_url(:large)) : nil
    } }
  end

  def review_teacher
    level = params[:level]
    status = params[:status].to_i
    ud = params[:ud]
    if status.present?
      ur = UserRole.where(user_id: ud, role_id: 1).take
      if ur.present?
        ur.status = status==1 ? true : false
        if status==1
          ur.role_type = level
        end
        if ur.save
          if level == '1'
            th_level = '市级'
          elsif level == '2'
            th_level = '区级'
          else
            th_level = '校级'
          end
          Notification.create!(user_id: ur.user_id, content: '您的教师身份审核'+(status==1 ? '通过! 角色为'+th_level : '未通过!'), message_type: 5)
          result = [true, '操作成功，即将推送消息告知被审核用户']
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
    @referees = UserProfile.joins(:comp_workers, :competitions, :user).where('comp_workers.status is NULL').where('comp_workers.user_id=user_profiles.user_id').where('competitions.id=comp_workers.competition_id').where('users.id=user_profiles.user_id').select(:user_id, :username, :school, :gender, :age, :grade, 'users.mobile', 'competitions.name', 'comp_workers.id').page(params[:page]).per(params[:per])
  end

  def review_referee
    status = params[:status].to_i
    comp_wd = params[:comp_wd]
    if comp_wd.present? && status.present?
      ck = CompWorker.joins(:competition).where(id: comp_wd).where('competitions.id=comp_workers.competition_id').select('comp_workers.id', 'comp_workers.competition_id', 'comp_workers.user_id', 'comp_workers.status', 'competitions.name').take
      if ck.present?
        ck.status = status==1 ? true : false
        if ck.save
          Notification.create!(user_id: ck.user_id, content: '您在'+ ck.name.to_s+'中的裁判身份审核'+(status==1 ? '通过!' : '未通过!'), message_type: 5)
          result = [true, '操作成功，即将推送消息告知被审核用户']
        else
          result = [false, '操作失败']
        end
      else
        result = [false, '角色不存在']
      end
    else
      result = [false, '参数不完整']
    end
    render json: result
  end

  def teacher_list
    @teachers = UserProfile.joins(:user_roles).where('user_roles.role_id=?', 1).where('user_roles.status is true').select(:id, :user_id, :username, :gender, :certificate, :school, :mobile, :teacher_no, 'user_roles.role_type').page(params[:page]).per(params[:per])
    @teacher_array = @teachers.map { |c| {
        id: c.id,
        user_id: c.user_id,
        school: c.school,
        mobile: c.mobile,
        num: c.teacher_no,
        username: c.username,
        gender: c.gender,
        role: c.role_type,
        certificate: c.certificate.present? ? ActionController::Base.helpers.asset_path(c.certificate_url(:large)) : nil
    } }
  end

  def referee_list
    @referees = UserProfile.joins(:comp_workers, :competitions, :user).where('comp_workers.status is not NULL').where('comp_workers.user_id=user_profiles.user_id').where('competitions.id=comp_workers.competition_id').where('users.id=user_profiles.user_id').select(:username, :school, :gender, :age, :grade, 'users.mobile', 'competitions.name').page(params[:page]).per(params[:per])
  end

  def points
    @points = UserPoint.joins(:prize).joins('inner join user_profiles u_p on u_p.user_id = user_points.user_id').where(is_audit: 0).select(:id, :is_audit, :cover, 'prizes.name', 'prizes.host_year', 'prizes.point', 'prizes.prize as prize_name', 'u_p.username').page(params[:page]).per(params[:per])
  end

  def point_list
    u_p = UserPoint.joins(:prize).joins('inner join user_profiles u_p on u_p.user_id = user_points.user_id').where(is_audit: 1)
    if params[:audit_status].present?
      @point_list = u_p.where(status: params[:audit_status]).select(:id, :is_audit, :status, :cover, 'prizes.name', 'prizes.host_year', 'prizes.point', 'prizes.prize as prize_name', 'u_p.username').page(params[:page]).per(params[:per])
    else
      @point_list = u_p.select(:id, :is_audit, :status, :cover, 'prizes.name', 'prizes.host_year', 'prizes.point', 'prizes.prize as prize_name', 'u_p.username').page(params[:page]).per(params[:per])
    end
  end

  def audit_point
    if params[:status].present? && params[:upd].present?
      u_p = UserPoint.find(params[:upd])
      if u_p.present?
        if u_p.update_attributes(is_audit: true, status: params[:status])
          result = [true, '审核成功']
        else
          result = [false, '审核失败']
        end
      else
        result=[false, '审核对象不存在']
      end
    else
      result =[false, '参数不完整']
    end
    render json: result
  end
end

