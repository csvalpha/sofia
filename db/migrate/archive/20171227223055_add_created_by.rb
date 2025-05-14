class AddCreatedBy < ActiveRecord::Migration[5.1]
  def change
    add_reference :activities, :created_by, references: :users, index: true
    add_foreign_key :activities, :users, column: :created_by_id
    add_reference :credit_mutations, :created_by, references: :users, index: true
    add_foreign_key :credit_mutations, :users, column: :created_by_id
    add_reference :orders, :created_by, references: :users, index: true
    add_foreign_key :orders, :users, column: :created_by_id
  end
end
