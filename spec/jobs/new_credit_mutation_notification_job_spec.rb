require 'rails_helper'

RSpec.describe NewCreditMutationNotificationJob do
  describe '#perform' do
    let(:user) { create(:user, name: 'Buddy Normal', email: 'bahamas@example.com') }
    let(:emails) { ActionMailer::Base.deliveries }
    let(:mutation) { create(:credit_mutation, user:, amount: -2.30) }

    subject(:job) { perform_enqueued_jobs { described_class.perform_now(mutation) } }

    before do
      ActionMailer::Base.deliveries = []
      job
    end

    context 'when with valid email address' do
      it { expect(emails.size).to eq 1 }
      it { expect(emails.first.to.first).to eq user.email }
      it { expect(emails.first.body.to_s).to include '2,30' }
    end

    context 'when with no email address' do
      let(:user) { create(:user, name: 'Buddy Normal', email: nil) }

      it { expect(emails.size).to eq 0 }
    end
  end
end
