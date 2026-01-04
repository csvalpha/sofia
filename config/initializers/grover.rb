# Grover Global Configuration
#
# Use this to set up shared configuration options for your entire application.
# Any of the configuration options shown here can also be applied to single
# models by passing arguments to the Grover.new call.
#
# To learn more, check out the README:
# https://github.com/Studiosity/grover

Grover.configure do |config|
  # Location of the chromium/chrome executable
  # config.options = {
  #   executable_path: ENV.fetch('GOOGLE_CHROME_SHIM', nil)
  # }

  # Common PDF options
  config.options = {
    format: 'A4',
    print_background: true,
    prefer_css_page_size: false,
    display_url: Rails.application.config.x.sofia_host || 'localhost'
  }
end
