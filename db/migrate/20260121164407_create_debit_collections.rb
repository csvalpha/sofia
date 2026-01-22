class CreateDebitCollections < ActiveRecord::Migration[7.2]
  def change
    create_table :debit_collections do |t|
      t.string :name, null: false
      t.date :collection_date, null: false
      t.references :author, foreign_key: { to_table: :users }
      t.string :status, null: false, default: 'pending'
      t.text :sepa_file_content
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :debit_collections, :collection_date
    add_index :debit_collections, :status
    add_index :debit_collections, :deleted_at
  end
end
