class AddDeviseToUsers < ActiveRecord::Migration[5.1]
  def self.up
    change_table :users do |t|
      t.string :name

      t.string :provider
      t.string :uid
    end
  end

  def self.down
    # By default, we don't want to make any assumption about how to roll back a migration when your
    # model already existed. Please edit below which fields you would like to remove in this migration.
    raise ActiveRecord::IrreversibleMigration
  end
end
