class AddProductPriceFoldersAndGridSize < ActiveRecord::Migration[7.2]
  def up
    create_product_price_folders
    add_positions_to_product_prices
    backfill_product_price_positions

    add_column :price_lists, :grid_size, :integer, default: 4
    add_check_constraint :price_lists, 'grid_size BETWEEN 2 AND 9', name: 'price_lists_grid_size_check'
  end

  def down
    remove_check_constraint :price_lists, name: 'price_lists_grid_size_check'
    remove_column :price_lists, :grid_size

    add_index :product_prices, :price_list_id
    remove_check_constraint :product_prices, name: 'product_prices_position_check'
    remove_index :product_prices, name: 'index_product_prices_on_folder_and_position'
    remove_column :product_prices, :position
    remove_reference :product_prices, :product_price_folder, foreign_key: true

    drop_table :product_price_folders
  end

  private

  def create_product_price_folders
    create_table :product_price_folders do |t|
      # Indexed by the composite (price_list_id, position) index below
      t.references :price_list, null: false, foreign_key: true, index: false
      t.string :name, null: false
      t.integer :position, null: false, default: 0
      t.string :color, null: false, default: '#6c757d'
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :product_price_folders, :deleted_at
    add_index :product_price_folders, %i[price_list_id position]
    add_check_constraint :product_price_folders, 'position >= 0', name: 'product_price_folders_position_check'
  end

  def add_positions_to_product_prices
    add_reference :product_prices, :product_price_folder, foreign_key: { on_delete: :nullify }, null: true
    add_column :product_prices, :position, :integer, null: false, default: 0
    add_check_constraint :product_prices, 'position >= 0', name: 'product_prices_position_check'

    # Covers price_list_id lookups, so the single-column index becomes redundant
    add_index :product_prices, %i[price_list_id product_price_folder_id position], name: 'index_product_prices_on_folder_and_position'
    remove_index :product_prices, :price_list_id, name: 'index_product_prices_on_price_list_id'
  end

  # Keep the previous order screen ordering (by product id) for existing price lists
  def backfill_product_price_positions
    execute <<~SQL.squish
      UPDATE product_prices
      SET position = numbered.row_number
      FROM (
        SELECT id, ROW_NUMBER() OVER (PARTITION BY price_list_id ORDER BY product_id) - 1 AS row_number
        FROM product_prices
      ) AS numbered
      WHERE product_prices.id = numbered.id
    SQL
  end
end
