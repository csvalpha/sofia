class AddPaymentModel < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.string :mollie_id
      t.decimal :amount, precision: 8, scale: 2
      t.integer :status, default: 0, null: false
      t.references :user

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
