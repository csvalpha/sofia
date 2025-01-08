require 'rails_helper'

RSpec.describe Invoice, type: :model do
  subject(:invoice) { build_stubbed(:invoice) }

  describe '#valid' do
    it { expect(invoice).to be_valid }

    context 'when without user' do
      subject(:invoice) { build_stubbed(:invoice, user: nil) }

      it { expect(invoice).not_to be_valid }
    end

    context 'when without activity' do
      subject(:invoice) { build_stubbed(:invoice, activity: nil) }

      it { expect(invoice).not_to be_valid }
    end
  end

  describe '#name' do
    context 'when with override' do
      subject(:invoice) { build(:invoice, name_override: 'Name') }

      it { expect(invoice.name).to eq 'Name' }
    end

    context 'when without override' do
      subject(:invoice) { build(:invoice) }

      it { expect(invoice.name).to eq invoice.user.name }
    end
  end

  describe '#email' do
    context 'when with override' do
      subject(:invoice) { build(:invoice, email_override: 'test@example.com') }

      it { expect(invoice.email).to eq 'test@example.com' }
    end

    context 'when without override' do
      subject(:invoice) { build(:invoice) }

      it { expect(invoice.email).to eq invoice.user.email }
    end
  end

  describe '#amount' do
    let(:activity) { create(:activity) }
    let(:user) { create(:user) }

    subject(:invoice) { build(:invoice, activity:, user:) }

    before do
      create_list(:order, 5, :with_items, user:, activity:)
      activity.update(locked_by: user)
      invoice.save
      invoice.reload
      create(:invoice_row, invoice:, amount: 5, price: 10)
    end

    it { expect(invoice.amount).to eq activity.revenue_by_user(user) + 50 }
  end

  describe '#set_human_id' do
    let(:activity) { create(:activity, :manually_locked) }
    let(:invoice) { build(:invoice, activity:) }

    before do
      create_list(:invoice, 2)
      invoice.save
    end

    it { expect(invoice.human_id).to eq "#{Time.zone.now.year}0003" }
  end
end
