class Admin::ChecksController < AdminController

  before_action do
    authenticate_permissions(['admin'])
  end

  def teachers
    @teachers = UserProfile.joins(:user_roles).joins('inner join schools s on user_profiles.school_id=s.id').where('user_roles.role_id=?', 1).where('user_roles.status is false').select(:id, :user_id, :username, :gender, :certificate, 's.name as school_name', :mobile, :teacher_no).page(params[:page]).per(params[:per])
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

  def teacher_list
    @teachers = UserProfile.joins(:user_roles).where('user_roles.role_id=?', 1).where('user_roles.status is true').select(:id, :user_id, :username, :gender, :certificate, :school_id, :mobile, :teacher_no, 'user_roles.role_type').page(params[:page]).per(params[:per])
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

  def schools
    @schools = School.joins('left join user_profiles u_p on u_p.user_id=schools.user_id').where(status: 0, audit: nil).select(:id, :name, :school_type, :district, 'u_p.username').page(params[:page]).per(params[:per])
  end

  def school_list
    @schools = School.joins('left join user_profiles u_p on u_p.user_id=schools.user_id').where(user_add: true).where('audit is not NULL').select(:id, :name, :school_type, :audit, :district, 'u_p.username').page(params[:page]).per(params[:per])
  end

  def review_school
    if request.method == 'POST'
      status = params[:status]
      school_id = params[:school_id].to_i
      if status.present? && school_id !=0
        school = School.find(school_id)
        if school.present? && school.user_id.present? && school.status == false && school.audit==nil
          if status
            school.status = status
          end
          school.audit = status
          if school.save
            result=[true, '审核成功']
          else
            result=[false, '审核失败']
          end
        else
          result=[false, '对象不存在']
        end
      else
        result=[false, '参数不完整']
      end
    else
      result=[false, '非法请求']
    end
    render json: result
  end

end

