class CreateProductPriceFolders < ActiveRecord::Migration[7.2]
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
  end
end
