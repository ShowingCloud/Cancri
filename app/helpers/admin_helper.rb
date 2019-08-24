module AdminHelper

  def show_status(bool)
    (bool ? '<label class="label label-success">是</label>' : '<label class= "label label-default">否</label>').html_safe
  end

  def show_permissions(admin)
    html = ''
    if admin.permissions.present?
      permissions = admin.permissions.split(',')
      Admin::PERMISSIONS.each do |id, name|
        if permissions.include?(id.to_s)
          html += '<label class="label label-success">' + name + '</label> '
        end
      end
    end
    html.html_safe
  end

  # 根据用户权限显示相应菜单
  def authenticate_permissions_show(permissions)
    if permissions.is_a?(Array) and @current_admin.permissions.present?
      (@current_admin.permissions.split(',') & permissions).count > 0
    else
      FALSE
    end
  end

  def show_teacher_role(role_type)
    case role_type
      when 1
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
        '外聘-校级'
      else
        '未知'
    end
  end

  def show_review_role_action(role_name)
    case role_name
      when '教师'
        'teachers'
      when '家庭创客'
        'hackers'
      when '志愿者'
        'volunteers'
      else
        ''
    end
  end

  def is_show_status(status)
    case status when 0
                  ('<label class="label label-danger">待显示</label>').html_safe
      when 1
        ('<label class="label label-primary">显示</label>').html_safe
      when 2
        ('<label class="label label-warning">结束</label>').html_safe
      else
        '未知'
    end
  end


end
