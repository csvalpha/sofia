class AddGridSizeToPriceLists < ActiveRecord::Migration[7.2]
  def change
    add_column :price_lists, :grid_size, :integer, default: 4
  end
end
