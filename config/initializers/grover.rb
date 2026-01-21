Grover.configure do |config|
  config.options = {
    viewport: {
      width: 794,  # A4 width in pixels at 96 DPI (210mm)
      height: 1123 # Starting height, will expand as needed
    },
    emulate_media: 'screen',
    print_background: true,
    executable_path: Rails.env.development? ? nil : '/usr/bin/chromium',
    launch_args: if Rails.env.development?
                   []
                 else
                   [
                     '--no-sandbox',
                     '--disable-setuid-sandbox',
                     '--disable-dev-shm-usage',
                     '--disable-gpu',
                     '--disable-software-rasterizer'
                   ]
                 end
  }
end
