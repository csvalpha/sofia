class AddUserAvatar < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :avatar_thumb_url, :string
  end
end
