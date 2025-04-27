require 'rails_helper'

RSpec.describe InvoiceRow do
  subject(:invoice_row) { build_stubbed(:invoice_row) }

  describe '#valid' do
    it { expect(invoice_row).to be_valid }

    context 'when without invoice' do
      subject(:invoice_row) { build_stubbed(:invoice_row, invoice: nil) }

      it { expect(invoice_row).not_to be_valid }
    end

    context 'when without name' do
      subject(:invoice_row) { build_stubbed(:invoice_row, name: nil) }

      it { expect(invoice_row).not_to be_valid }
    end

    context 'when without amount' do
      subject(:invoice_row) { build_stubbed(:invoice_row, amount: nil) }

      it { expect(invoice_row).not_to be_valid }
    end

    context 'when without price' do
      subject(:invoice_row) { build_stubbed(:invoice_row, price: nil) }

      it { expect(invoice_row).not_to be_valid }
    end
  end

  describe '#total' do
    subject(:invoice_row) { build_stubbed(:invoice_row, amount: 5, price: 2) }

    it { expect(invoice_row.total).to eq 10 }
  end
end
