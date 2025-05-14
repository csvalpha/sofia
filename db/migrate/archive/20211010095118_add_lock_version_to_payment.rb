class AddLockVersionToPayment < ActiveRecord::Migration[6.1]
  def change
    add_column :payments, :lock_version, :integer
  end
end
