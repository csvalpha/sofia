class AddColorToProducts < ActiveRecord::Migration[7.2]
  def change
    add_column :products, :color, :string, default: '#f8f9fa'
  end
end
