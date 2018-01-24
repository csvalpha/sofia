class AddCategoryToProduct < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :category, :integer, default: 0
  end
end
