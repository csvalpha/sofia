class AddInvoiceToPayment < ActiveRecord::Migration[6.0]
  def change
    add_reference :payments, :invoice, references: :invoices, index: true
  end
end
