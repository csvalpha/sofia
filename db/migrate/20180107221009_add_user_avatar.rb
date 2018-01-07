class AddUserAvatar < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :avatar_uid, :string
  end
end
