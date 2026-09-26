class EnforceDatabaseConsistencyConstraints < ActiveRecord::Migration[7.2]
  def change
    remove_redundant_indexes
    fix_sofia_accounts_unique_index
    add_missing_foreign_keys
    add_missing_not_null_constraints
    add_missing_check_constraints
    add_email_uniqueness_index
  end

  private

  def remove_redundant_indexes
    # Both are fully covered by the composite index index_roles_users_on_user_id_and_role_id_and_created_at
    remove_index :roles_users, :user_id, name: 'index_roles_users_on_user_id'
    # Both are fully covered by the composite index index_product_prices_on_product_id_and_price_list_id
    remove_index :product_prices, :product_id, name: 'index_product_prices_on_product_id'
  end

  def fix_sofia_accounts_unique_index
    remove_index :sofia_accounts, :user_id, name: 'index_sofia_accounts_on_user_id'
    add_index :sofia_accounts, :user_id, unique: true
  end

  def add_missing_foreign_keys
    add_foreign_key :roles_users, :users
    add_foreign_key :roles_users, :roles
    add_foreign_key :product_prices, :products
    add_foreign_key :product_prices, :price_lists
    add_foreign_key :payments, :users
    add_foreign_key :payments, :invoices
    add_foreign_key :order_rows, :orders
    add_foreign_key :order_rows, :products
    add_foreign_key :orders, :activities
    add_foreign_key :orders, :users
    add_foreign_key :invoice_rows, :invoices
    add_foreign_key :invoices, :users
    add_foreign_key :invoices, :activities
    add_foreign_key :credit_mutations, :users
    add_foreign_key :credit_mutations, :activities
    add_foreign_key :activities, :price_lists
  end

  def add_missing_not_null_constraints
    change_column_null :roles, :role_type, false

    change_table :product_prices, bulk: true do |t|
      t.change_null :product_id, false
      t.change_null :price_list_id, false
      t.change_null :price, false
    end

    change_column_null :payments, :amount, false
    change_column_null :orders, :created_by_id, false
    change_column_null :invoice_rows, :invoice_id, false
    change_column_null :credit_mutations, :created_by_id, false

    change_table :activities, bulk: true do |t|
      t.change_null :price_list_id, false
      t.change_null :created_by_id, false
    end

    change_column_null :users, :name, false
  end

  def add_missing_check_constraints
    add_check_constraint :order_rows, 'product_count >= 0', name: 'order_rows_product_count_check'
    add_check_constraint :order_rows, 'price_per_product > 0', name: 'order_rows_price_per_product_check'
    add_check_constraint :credit_mutations, 'amount <= 5000', name: 'credit_mutations_amount_check'
  end

  def add_email_uniqueness_index
    # Only sofia_account and manually created users sign up with their own email address.
    # Amber-synced accounts (provider: 'amber_oauth2') are managed externally and are excluded.
    add_index :users, 'lower(email)',
              name: 'index_users_on_lower_email_for_sofia_and_manual',
              unique: true,
              where: "deleted_at IS NULL AND email IS NOT NULL AND provider IS DISTINCT FROM 'amber_oauth2'"
  end
end
