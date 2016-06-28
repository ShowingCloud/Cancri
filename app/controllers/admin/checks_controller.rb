class Admin::ChecksController < AdminController

  before_action do
    authenticate_permissions(['admin'])
  end

  def teachers
    @teachers = UserProfile.joins(:user_roles).joins('inner join schools s on user_profiles.school_id=s.id').where('user_roles.role_id=?', 1).where('user_roles.status=?', 0).select(:id, :user_id, :username, :gender, :certificate, 'user_roles.cover as cover', 's.name as school_name', :mobile, :teacher_no).page(params[:page]).per(params[:per])
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
          Notification.create!(user_id: ur.user_id, content: '您的教师身份审核'+(status==1 ? '通过! 角色为'+th_level : '未通过!'), message_type: 0)
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
    @teachers = UserProfile.joins(:user_roles, :school).where('user_roles.role_id=?', 1).where('user_roles.status=?', 1).select(:id, :user_id, :username, :gender, :certificate, :school_id, 'schools.name as school_name', :mobile, :teacher_no, 'user_roles.role_type').page(params[:page]).per(params[:per])
    @teacher_array = @teachers.map { |c| {
        id: c.id,
        user_id: c.user_id,
        school: c.school_name,
        mobile: c.mobile,
        num: c.teacher_no,
        username: c.username,
        gender: c.gender,
        role: c.role_type,
        certificate: c.certificate.present? ? ActionController::Base.helpers.asset_path(c.certificate_url) : nil
    } }
  end

  def hackers
    @hackers = UserRole.joins('inner join user_profiles u_p on u_p.user_id = user_roles.user_id').joins('left join schools s on s.id = u_p.school_id').joins('left join districts d on u_p.district_id = d.id').where('user_roles.role_id=?', 2).where('user_roles.status=?', 0)
                   .select(:id, :cover, :desc, 's.name as school_name', 'd.name as district_name', 'u_p.username', 'u_p.gender').page(params[:page]).per(params[:per])
    @hackers_array = @hackers.map { |c| {
        id: c.id,
        username: c.username,
        gender: c.gender,
        school: c.school_name,
        district: c.district_name,
        desc: c.desc,
        cover: c.cover.present? ? ActionController::Base.helpers.asset_path(c.cover_url) : nil
    } }
  end

  def hacker_list
    @hackers = UserRole.joins('inner join user_profiles u_p on u_p.user_id = user_roles.user_id').joins('left join schools s on s.id = u_p.school_id').joins('left join districts d on u_p.district_id = d.id').where('user_roles.role_id=?', 2).where('user_roles.status=?', 1)
                   .select(:id, :cover, :desc, 's.name as school_name', 'd.name as district_name', 'u_p.username', 'u_p.gender').page(params[:page]).per(params[:per])
    @hackers_array = @hackers.map { |c| {
        id: c.id,
        username: c.username,
        gender: c.gender,
        school: c.school_name,
        district: c.district_name,
        desc: c.desc,
        cover: c.cover.present? ? ActionController::Base.helpers.asset_path(c.cover_url) : nil
    } }
  end

  def review_hacker
    status = params[:status]
    id = params[:id]
    if status.present?
      ur = UserRole.find(id)
      if ur.present?
        ur.status = status=='1' ? 1 : 2
        if ur.save
          Notification.create!(user_id: ur.user_id, content: '您的家庭创客身份审核'+(status=='1' ? '通过!' : '未通过!'), message_type: 0)
          result = [true, '操作成功，即将推送消息告知被审核用户']
        else
          result = [false, '操作失败']
        end
      else
        result = [false, '该角色不存在']
      end
    else
      result = [false, '请选择审核结果']
    end
    render json: result
  end

  def schools
    @schools = School.joins('left join user_profiles u_p on u_p.user_id=schools.user_id').where(status: 0, audit: nil).select(:id, :name, :school_type, :district_id, 'u_p.username').page(params[:page]).per(params[:per])
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

