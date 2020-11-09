require 'rails_helper'

RSpec.describe ActivityInvoiceJob, type: :job do
  describe '#perform' do
    let(:activity) { FactoryBot.create(:activity) }
    let(:manual_users) { FactoryBot.create_list(:user, 3) }
    let(:external_users) { FactoryBot.create_list(:user, 2, provider: 'some_provider') }
    let(:emails) { ActionMailer::Base.deliveries }

    subject(:job) { perform_enqueued_jobs { described_class.perform_now(activity) } }

    before do
      ActionMailer::Base.deliveries = []

      manual_users.each{ |u| FactoryBot.create(:order_with_items, user: u, activity: activity ) }
      external_users.each{ |u| FactoryBot.create(:order_with_items, user: u, activity: activity ) }
      activity.update(locked_by: FactoryBot.create(:user))

      job
    end

    context 'when with manual user orders' do
      it { expect(emails.size).to eq 3 }
      it { expect(Invoice.count).to eq 3 }
      it { expect(Invoice.last.status).to eq 'sent'}
    end
  end
end
