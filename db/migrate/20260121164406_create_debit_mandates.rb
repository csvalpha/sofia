class CreateDebitMandates < ActiveRecord::Migration[7.2]
  def change
    create_table :debit_mandates do |t|
      t.references :user, null: false, foreign_key: true
      t.string :iban, null: false
      t.string :iban_holder, null: false
      t.string :mandate_reference, null: false
      t.date :start_date, null: false
      t.date :end_date
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :debit_mandates, :iban
    add_index :debit_mandates, :mandate_reference, unique: true
    add_index :debit_mandates, :deleted_at
  end
end
