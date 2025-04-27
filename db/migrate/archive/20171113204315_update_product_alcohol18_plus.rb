class UpdateProductAlcohol18Plus < ActiveRecord::Migration[5.1]
  def change
    rename_column :products, :contains_alcohol, :requires_age

    add_index :product_prices, %i[product_id price_list_id], unique: true
  end
end
