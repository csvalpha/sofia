class CreateSofiaAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :sofia_accounts do |t|
      t.string :username, unique: true, null: false
      t.string :password_digest, null: false
      t.references :user, null: false, unique: true
      t.string :otp_secret_key, null: false
      t.boolean :otp_enabled, default: false

      t.datetime :deleted_at
      t.timestamps

      t.index :username, unique: true
    end

    add_column :users, :activation_token, :string
    add_column :users, :activation_token_valid_till, :datetime

    remove_index :roles, column: %i[role_type group_uid]
    change_column_null :roles, :group_uid, true, 999_999
  end
end
