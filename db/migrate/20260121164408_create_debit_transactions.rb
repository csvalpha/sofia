class CreateDebitTransactions < ActiveRecord::Migration[7.2]
  def change
    create_table :debit_transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :collection, null: false, foreign_key: { to_table: :debit_collections }
      t.references :mandate, null: false, foreign_key: { to_table: :debit_mandates }
      t.string :description, null: false
      t.decimal :amount, precision: 8, scale: 2, null: false
      t.string :status, null: false, default: 'pending'
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :debit_transactions, :status
    add_index :debit_transactions, :deleted_at
  end
end
