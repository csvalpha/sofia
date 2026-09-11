module ApplicationHelper
  # TODO: Spec this method
  # :nocov:
  def nav_link(name = nil, options = nil, html_options = nil, &)
    options&.merge!(class: 'active') { |_, v1, v2| [v1, v2].join ' ' } if current_page?(name)

    link_to(name, options, html_options, &)
  end

  def flash_class(level)
    {
      'notice' => 'alert-info',
      'success' => 'alert-success',
      'error' => 'alert-danger',
      'alert' => 'alert-warning'
    }[level]
  end

  def remove_empty(hash)
    hash.each_with_object({}) do |(k, v), squeezed_hash|
      if v.is_a?(Hash)
        squeezed_hash[k] = remove_empty(v).reject { |_, value| value.empty? }
      else
        squeezed_hash[k] = v unless v.empty?
      end
    end
  end
end
