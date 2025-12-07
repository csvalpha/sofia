class AddMollieMandateToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :mollie_customer_id, :string
    add_column :users, :mollie_mandate_id, :string
    add_column :users, :auto_charge_enabled, :boolean, default: false, null: false

    add_index :users, :mollie_customer_id, unique: true
    add_index :users, :mollie_mandate_id, unique: true
  end
end
