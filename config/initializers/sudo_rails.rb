SudoRails.setup do |config|
  config.enabled = true
  config.sudo_session_duration = 10.minutes
  config.layout = 'application'
  config.reset_pass_link = nil
end
