class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@societeitflux.nl',
          reply_to: 'penningmeester@societeitflux.nl'
  layout 'mailer'
end
