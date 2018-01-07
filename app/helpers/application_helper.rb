module ApplicationHelper
  def nav_link(name = nil, options = nil, html_options = nil, &block)
    if current_page?(name)
      options&.merge!(class: 'active') { |_, v1, v2| [v1, v2].join ' ' }
    end

    link_to(name, options, html_options, &block)
  end

  def flash_class(level)
    case level
    when 'notice' then 'alert-info'
    when 'success' then 'alert-success'
    when 'error' then 'alert-danger'
    when 'alert' then 'alert-warning'
    end
  end

  def datetime_short(datetime)
    datetime.strftime('%d-%m %H:%M')
  end

  def datetime(datetime)
    datetime.strftime('%d %B %Y %H:%M')
  end

  def date(datetime)
    datetime.strftime('%d-%b-%y')
  end

  def time(datetime)
    datetime.strftime('%H:%M')
  end
end
