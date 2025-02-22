require 'rspec/expectations'

RSpec::Matchers.define :send_email do |mailer_action, mailer_when, mailer_args|
  match do |mailer_class|
    message_delivery = instance_double(ActionMailer::MessageDelivery)
    expect(mailer_class).to receive(mailer_action).with(mailer_args).and_return(message_delivery) # rubocop:disable RSpec/StubbedMock, RSpec/MessageSpies
    allow(message_delivery).to receive(mailer_when)
  end
end
