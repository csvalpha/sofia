class AddProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :products do |t|
      t.string :title, null: false

      t.datetime :deleted_at
      t.timestamps
    end

    create_table :price_lists do |t|
      t.string :title, null: false

      t.datetime :deleted_at
      t.timestamps
    end

    create_table :product_prices do |t|
      t.references :product
      t.references :price_list

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
