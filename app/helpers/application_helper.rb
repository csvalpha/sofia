module ApplicationHelper
  # TODO: Spec this method
  # :nocov:
  def nav_link(name = nil, options = nil, html_options = nil, &block)
    options&.merge!(class: 'active') { |_, v1, v2| [v1, v2].join ' ' } if current_page?(name)

    link_to(name, options, html_options, &block)
  end

  def flash_class(level)
    {
      'notice' => 'alert-info',
      'success' => 'alert-success',
      'error' => 'alert-danger',
      'alert' => 'alert-warning'
    }[level]
  end
end
