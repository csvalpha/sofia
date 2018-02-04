class AddCategoryToProduct < ActiveRecord::Migration[5.1]
  def up
    change_table :products do |t|
      t.column :category, :integer, null: false, default: 0
      t.remove :requires_age
    end
  end

  def down
    change_table :products do |t|
      t.remove :category
      t.column :requires_age, :boolean, null: false, default: false
    end
  end
end
