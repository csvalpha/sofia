# config/initializers/sudo_rails.rb
SudoRails.setup do |config|
  # On/off engine
  config.enabled = true

  # Sudo mode sessions duration, default is 30 minutes
  config.sudo_session_duration = 10.minutes

  # Confirmation page styling
  config.layout = 'application'

  # Confirmation strategy implementation
  config.confirm_strategy = -> (context, password) {
    user = context.current_user
    password == "test"
  }

  config.reset_pass_link = nil
end
