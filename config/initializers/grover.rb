# Grover Global Configuration
#
# Use this to set up shared configuration options for your entire application.
# Any of the configuration options shown here can also be applied to single
# models by passing arguments to the Grover.new call.
#
# To learn more, check out the README:
# https://github.com/Studiosity/grover

Grover.configure do |config|
  options = {
    format: 'A4',
    print_background: true,
    prefer_css_page_size: false,
    display_url: "https://#{Rails.application.config.x.sofia_host}"
  }

  unless Rails.env.development?
    options[:executable_path] = '/usr/bin/chromium'
    options[:launch_args] = ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage']
  end

  config.options = options
end
