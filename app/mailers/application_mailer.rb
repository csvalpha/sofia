class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.config.x.from_email,
          reply_to: Rails.application.config.x.treasurer_email
  layout 'mailer'
end
