class AddOrdersAndRenameTransactionToOrderItems < ActiveRecord::Migration[5.1]
  def change
    create_table :orders do |t|
      t.decimal :order_total, precision: 8, scale: 2
      t.references :activity, null: false
      t.references :user, null: false

      t.datetime :deleted_at
      t.timestamps
    end

    create_table :order_rows do |t|
      t.references :order, null: false
      t.references :product, null: false

      t.integer :product_count, null: false
      t.decimal :product_price_total, precision: 8, scale: 2, null: false
    end

    drop_table :transactions
  end
end
