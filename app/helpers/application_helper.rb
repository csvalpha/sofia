module ApplicationHelper
  # TODO: Spec this method
  # :nocov:
  def nav_link(name = nil, options = nil, html_options = nil, &block)
    options&.merge!(class: 'active') { |_, v1, v2| [v1, v2].join ' ' } if current_page?(name)

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
end
