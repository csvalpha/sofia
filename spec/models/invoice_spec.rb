require 'rails_helper'

RSpec.describe Invoice, type: :model do
  subject(:invoice) { FactoryBot.build_stubbed(:invoice) }

  describe '#valid' do
    it { expect(invoice).to be_valid }

    context 'when without user' do
      subject(:invoice) { FactoryBot.build_stubbed(:invoice, user: nil) }

      it { expect(invoice).not_to be_valid }
    end

    context 'when without activity' do
      subject(:invoice) { FactoryBot.build_stubbed(:invoice, activity: nil) }

      it { expect(invoice).not_to be_valid }
    end

    context 'when without amount' do
      subject(:invoice) { FactoryBot.build_stubbed(:invoice, amount: nil) }

      it { expect(invoice).not_to be_valid }
    end
  end

  describe '#set_amount' do
    let(:activity) { FactoryBot.create(:activity) }
    let(:user) { FactoryBot.create(:user) }
    subject(:invoice) { FactoryBot.build(:invoice, activity: activity, user: user)}

    before do
      FactoryBot.create_list(:order, 5, :with_items, user: user, activity: activity)
      invoice.save
      invoice.reload
    end

    it { expect(invoice.amount).to eq activity.revenue_by_user(user)}
  end
end
