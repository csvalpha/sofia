class AddTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :transactions do |t|
      t.datetime :timestamp, null: false
      t.references :product, null: false
      t.references :activity, null: false
      t.decimal :amount, precision: 8, scale: 2

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
