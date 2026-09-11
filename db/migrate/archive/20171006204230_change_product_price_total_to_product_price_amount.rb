class ChangeProductPriceTotalToProductPriceAmount < ActiveRecord::Migration[5.1]
  def change
    rename_column :order_rows, :product_price_total, :price_per_product
    remove_column :orders, :order_total
  end
end
