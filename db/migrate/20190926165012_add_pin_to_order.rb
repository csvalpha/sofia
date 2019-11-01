class AddPinToOrder < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :paid_with_pin, :boolean, default: false, null: false
  end
end
