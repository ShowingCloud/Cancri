module ApplicationHelper
  def render_page_title
    site_name = Settings.site_name
    title = @page_title ? "#{@page_title} - #{site_name}" : site_name
    content_tag('title', title, nil, false)
  end

  def iframe_src(path)
    url = URI.join(Settings.auth_url, path)
    url.query = URI.encode_www_form([['service', request.base_url], %w(iframe 1)])
    url
  end

  def show_gender(gender)
    case gender
    when 1
      '男'
    when 2
      '女'
    end
  end

  def show_team_status(status)
    case status
    when 0
      '未提交'
    when 1
      '报名成功'
    when 2
      '待学校审核'
    when 3
      '待区县审核'
    when -2
      '学校审核未通过'
    when -3
      '区县审核未通过'
    else
      '未知'
    end
  end

  def get_area
    case cookies[:area]
    when '1'
      'bs'
    else
      'default'
    end
  end
end
