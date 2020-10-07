class ExtendInvoiceModel < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :email_override, :string
    add_column :invoices, :name_override, :string
  end
end
