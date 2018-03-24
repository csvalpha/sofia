class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@csvalpha.nl',
          reply_to: 'penningmeester@societeitflux.nl'
  layout 'mailer'
end
