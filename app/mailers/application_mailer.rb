class ApplicationMailer < ActionMailer::Base
  default from: config.x.from_email,
          reply_to: config.x.treasurer_email
  layout 'mailer'
end
