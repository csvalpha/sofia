class CreateSofiaAccounts < ActiveRecord::Migration[7.2]
  def change
    create_table :sofia_accounts do |t|
      t.string :username, null: false
      t.string :password_digest, null: false
      t.references :user, null: false, foreign_key: true
      t.string :otp_secret_key
      t.boolean :otp_enabled, default: false, null: false

      t.datetime :deleted_at
      t.timestamps

      t.index :username, unique: true
    end

    change_table :users, bulk: true do |t|
      t.string :activation_token
      t.datetime :activation_token_valid_till
    end

    remove_index :roles, column: %i[role_type group_uid]
    change_column_null :roles, :group_uid, true, 999_999
  end
end
