class AddCashToOrder < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :paid_with_cash, :boolean, default: false, null: false
    change_column_null :orders, :user_id, true
  end
end
