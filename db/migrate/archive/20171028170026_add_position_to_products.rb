class AddPositionToProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :position, :integer, default: 0

    rename_column :product_prices, :amount, :price
  end
end
