class AddCreditMutation < ActiveRecord::Migration[5.1]
  def change
    create_table :credit_mutations do |t|
      t.string     :description, null: false
      t.references :user,        null: false
      t.references :activity
      t.decimal    :amount,      precision: 8, scale: 2, null: false

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
