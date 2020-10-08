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
  end

    describe '#amount' do
      let(:activity) { FactoryBot.create(:activity) }
      let(:user) { FactoryBot.create(:user) }

      subject(:invoice) { FactoryBot.build(:invoice, activity: activity, user: user) }

      before do
        FactoryBot.create_list(:order, 5, :with_items, user: user, activity: activity)
        activity.update(locked_by: user)
        invoice.save
        invoice.reload
        FactoryBot.create(:invoice_row, invoice: invoice, amount: 5, price: 10)
      end

      it { expect(invoice.amount).to eq activity.revenue_by_user(user) + 50 }
    end

    describe '#set_human_id' do
      let(:activity) { FactoryBot.create(:activity, :manually_locked) }
      let(:invoice) { FactoryBot.build(:invoice, activity: activity) }

      before do
        FactoryBot.create_list(:invoice, 2)
        invoice.save
      end

      it { expect(invoice.human_id).to eq "#{Time.zone.now.year}0003" }
    end
  end
