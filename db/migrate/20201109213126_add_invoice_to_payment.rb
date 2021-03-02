class AddInvoiceToPayment < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :token, :string
    add_index :invoices, :token, unique: true
    add_reference :payments, :invoice, references: :invoices, index: true
  end
end
