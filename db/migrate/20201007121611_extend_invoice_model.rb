class ExtendInvoiceModel < ActiveRecord::Migration[6.0]
  def change
    add_column :invoices, :email_override, :string
    add_column :invoices, :name_override, :string
    remove_column :invoices, :amount

    create_table :invoice_rows do |t|
      t.references :invoice
      t.string :name, null: false
      t.integer :amount, null: false
      t.decimal :price, precision: 8, scale: 2, null: false

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
