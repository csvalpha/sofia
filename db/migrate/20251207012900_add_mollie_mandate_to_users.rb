class AddMollieMandateToUsers < ActiveRecord::Migration[7.2]
  def change
    change_table :users, bulk: true do |t|
      t.column :mollie_customer_id, :string
      t.column :mollie_mandate_id, :string
      t.column :auto_charge_enabled, :boolean, default: false, null: false
      t.index :mollie_customer_id, unique: true
      t.index :mollie_mandate_id, unique: true
    end
  end
end
