class AddCategoryToProduct < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :category, :string, null: false, default: 'bier'
    Product.all.map{ |p| p.category = 'bier' && p.save }
  end
end
