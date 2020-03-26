Mollie::Client.configure do |config|
  config.api_key = Rails.application.config.x.mollie_api_key
end
