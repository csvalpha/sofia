class AddProductPriceFoldersAndGridSize < ActiveRecord::Migration[7.2]
  def change
    create_table :product_price_folders do |t|
      t.references :price_list, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :position, null: false, default: 0
      t.string :color, null: false, default: '#6c757d'
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :product_price_folders, :deleted_at
    add_index :product_price_folders, %i[price_list_id position]

    add_reference :product_prices, :product_price_folder, foreign_key: true, null: true
    add_column :product_prices, :position, :integer, null: false, default: 0
    add_index :product_prices, %i[price_list_id product_price_folder_id position], name: 'index_product_prices_on_folder_and_position'

    add_column :price_lists, :grid_size, :integer, default: 4
  end
end
