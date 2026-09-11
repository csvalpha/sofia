class RemovePositionFromAddCategoryToProduct < ActiveRecord::Migration[5.1]
  def change
    remove_column :products, :position

    add_column :products, :contains_alcohol, :boolean, null: false, default: false
  end
end
