require 'rails_helper'

RSpec.describe CreditInsufficientNotificationJob, type: :job do
  describe '#perform' do
    let(:user) { FactoryBot.create(:user) }
    let(:negative_user) { FactoryBot.create(:user, email: 'user@csvalpha.nl') }
    let(:negative_user_without_email) { FactoryBot.create(:user, email: nil, provider: 'some_external_source') }
    let(:user_without_email) { FactoryBot.create(:user, email: nil, provider: 'some_external_source') }
    let(:treasurer) do
      FactoryBot.create(:user,
                        roles: [FactoryBot.create(:role, role_type: :treasurer)],
                        email: 'treasurer@csvalpha.nl')
    end
    let(:mail) { ActionMailer::Base.deliveries }

    subject(:job) { perform_enqueued_jobs { CreditInsufficientNotificationJob.perform_now } }

    before do
      ActionMailer::Base.deliveries = []
      user
      FactoryBot.create(:credit_mutation, user: negative_user, amount: -2)
      FactoryBot.create(:credit_mutation, user: negative_user_without_email, amount: -2)
      user_without_email
      treasurer
      job
    end

    it { expect(mail.size).to eq 2 }
    it { expect(mail.first.to.first).to eq negative_user.email }
    it { expect(mail.first.body.to_s).to include "http://testhost:1337/users/#{negative_user.id}" }
    it { expect(mail.second.to.first).to eq treasurer.email }
    it { expect(mail.second.body.to_s).to include negative_user_without_email.name }
    it { expect(mail.second.body.to_s).not_to include user_without_email.name }
  end
end
