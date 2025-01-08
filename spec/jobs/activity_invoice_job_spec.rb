require 'rails_helper'

RSpec.describe ActivityInvoiceJob, type: :job do
  describe '#perform' do
    let(:activity) { create(:activity) }
    let(:manual_users) { create_list(:user, 3) }
    let(:external_users) { create_list(:user, 2, provider: 'some_provider') }

    subject(:job) { perform_enqueued_jobs { described_class.perform_now(activity) } }

    before do
      manual_users.each { |u| create(:order_with_items, user: u, activity:) }
      external_users.each { |u| create(:order_with_items, user: u, activity:) }
      activity.update(locked_by: create(:user))

      job
    end

    context 'when with manual user orders' do
      it { expect(Invoice.count).to eq 3 }
      it { expect(Invoice.last.status).to eq 'pending' }
    end
  end
end
