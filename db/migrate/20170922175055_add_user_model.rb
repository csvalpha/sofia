class AddUserModel < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :username, null: false

      t.datetime :deleted_at
      t.timestamps
    end

    change_table :transactions do |t|
      t.references :user
    end
  end
end
