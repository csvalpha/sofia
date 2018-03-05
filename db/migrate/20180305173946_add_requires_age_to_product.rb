class AddRequiresAgeToProduct < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :requires_age, :boolean, null: false, default: false
  end
end
