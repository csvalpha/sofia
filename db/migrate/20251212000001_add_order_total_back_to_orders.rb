class AddOrderTotalBackToOrders < ActiveRecord::Migration[7.2]
  def change
    add_column :orders, :order_total, :decimal, precision: 8, scale: 2 unless column_exists?(:orders, :order_total)
  end
end
