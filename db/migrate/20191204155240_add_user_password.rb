class AddUserPassword < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :encrypted_password, :string
  end
end
