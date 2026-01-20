Grover.configure do |config|
  config.options = {
    format: 'A4',
    print_background: true,
    executable_path: Rails.env.development? ? nil : '/usr/bin/chromium',
    launch_args: Rails.env.development? ? [] : [
      '--no-sandbox',
      '--disable-setuid-sandbox',
      '--disable-dev-shm-usage',
      '--disable-gpu',
      '--disable-software-rasterizer',
      '--hide-scrollbars'
    ]
  }
end
