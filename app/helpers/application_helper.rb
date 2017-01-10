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

  def show_teacher_type(role_type)
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

end
