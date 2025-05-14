class AddParanoia < ActiveRecord::Migration[5.1]
  def change
    add_column :order_rows, :deleted_at, :datetime
  end
end
