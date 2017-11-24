class AddUidIndexToUser < ActiveRecord::Migration[5.1]
  def change
    add_index :users, :uid
  end
end
