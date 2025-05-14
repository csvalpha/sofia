class AddActivityLock < ActiveRecord::Migration[5.2]
  def change
    add_reference :activities, :locked_by, references: :users, index: true
    add_foreign_key :activities, :users, column: :locked_by_id
  end
end
