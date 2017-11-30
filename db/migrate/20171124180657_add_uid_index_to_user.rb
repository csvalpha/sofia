class AddUidIndexToUser < ActiveRecord::Migration[5.1]
  def change
    add_index :users, :uid, unique: true
  end
end
