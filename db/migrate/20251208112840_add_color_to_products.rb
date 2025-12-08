class AddColorToProducts < ActiveRecord::Migration[7.2]
  class Product < ActiveRecord::Base
    self.table_name = 'products'
  end

  def up
    add_column :products, :color, :string, default: '#f8f9fa', null: false
  end

  def down
    remove_column :products, :color
  end
end
