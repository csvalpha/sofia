class CreateInvoices < ActiveRecord::Migration[5.2]
  def change
    create_table :invoices do |t|
      t.string :human_id, unique: true, null: false
      t.references :user, null: false
      t.references :activity, null: false
      t.decimal :amount, precision: 8, scale: 2

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
