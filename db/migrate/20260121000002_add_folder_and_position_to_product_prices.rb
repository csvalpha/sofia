class AddFolderAndPositionToProductPrices < ActiveRecord::Migration[7.2]
  def change
    add_reference :product_prices, :product_price_folder, foreign_key: true, null: true
    add_column :product_prices, :position, :integer, null: false, default: 0

    add_index :product_prices, %i[price_list_id product_price_folder_id position], name: 'index_product_prices_on_folder_and_position'
  end
end
