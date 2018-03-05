require 'rails_helper'

RSpec.describe NegativeCreditMailerJob, type: :job do
  describe '#perform' do
    let(:user) { FactoryBot.create(:user) }
    let(:negative_user) { FactoryBot.create(:user) }
    let(:mail_unknown_negative_user) { FactoryBot.create(:user, email: nil, provider: 'some_external_source') }
    let(:mail_unknown_user) { FactoryBot.create(:user, email: nil, provider: 'some_external_source') }
    let(:treasurer) { FactoryBot.create(:user, roles: [FactoryBot.create(:role, role_type: :treasurer)]) }
    let(:mail) { ActionMailer::Base.deliveries }

    subject(:job) do
      perform_enqueued_jobs do
        NegativeCreditMailerJob.perform_now
      end
    end

    before do
      ActionMailer::Base.deliveries = []
      user
      FactoryBot.create(:credit_mutation, user: negative_user, amount: -2)
      FactoryBot.create(:credit_mutation, user: mail_unknown_negative_user, amount: -2)
      mail_unknown_user
      treasurer
      job
    end

    it { expect(mail.size).to eq 2 }
    it { expect(mail.first.to.first).to eq negative_user.email }
    it { expect(mail.first.body.to_s).to include '-2' }
    it { expect(mail.second.to.first).to eq treasurer.email }
    it { expect(mail.second.body.to_s).to include mail_unknown_negative_user.name }
    it { expect(mail.second.body.to_s).not_to include mail_unknown_user.name }
  end
end
