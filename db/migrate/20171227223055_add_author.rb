class AddAuthor < ActiveRecord::Migration[5.1]
  def change
    add_reference :activities, :author, index: true
    add_reference :credit_mutations, :author, index: true
    add_reference :orders, :author, index: true
  end
end
