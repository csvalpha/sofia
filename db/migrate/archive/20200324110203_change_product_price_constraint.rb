class ChangeProductPriceConstraint < ActiveRecord::Migration[6.0]
  def change
    remove_index :product_prices, %i[product_id price_list_id]
    add_index :product_prices, %i[product_id price_list_id deleted_at],
              name: 'index_product_prices_on_product_id_and_price_list_id', unique: true
  end
end
