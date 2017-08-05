class AddProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :products do |t|
      t.string :name, null: false

      t.datetime :deleted_at
      t.timestamps
    end

    create_table :price_lists do |t|
      t.string :name, null: false

      t.datetime :deleted_at
      t.timestamps
    end

    create_table :product_prices do |t|
      t.references :product
      t.references :price_list
      t.decimal :amount, precision: 8, scale: 2

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
