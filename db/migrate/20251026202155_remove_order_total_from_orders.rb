class RemoveOrderTotalFromOrders < ActiveRecord::Migration[7.2]
  def change
    remove_column :orders, :order_total, :decimal, precision: 8, scale: 2
  end
end
