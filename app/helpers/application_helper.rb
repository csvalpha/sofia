module ApplicationHelper
  def nav_link(name = nil, options = nil, html_options = nil, &block)
    if current_page?(name)
      options&.merge!(class: 'active') { |_, v1, v2| [v1, v2].join ' ' }
    end

    link_to(name, options, html_options, &block)
  end
end
