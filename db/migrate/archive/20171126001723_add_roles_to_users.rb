class AddRolesToUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :roles do |t|
      t.string :name, null: false
      t.integer :group_uid, null: false

      t.datetime :deleted_at
      t.timestamps
    end

    create_table :roles_users do |t|
      t.references :user, null: false
      t.references :role, null: false

      t.datetime :deleted_at
      t.timestamps
    end

    add_index :roles, %i[name group_uid], unique: true
    add_index :roles_users, %i[user_id role_id created_at], unique: true
  end
end
