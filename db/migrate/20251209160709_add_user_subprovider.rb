class AddUserSubprovider < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :sub_provider, :string
    add_index :users, :sub_provider
  end
end

