class AddActivities < ActiveRecord::Migration[5.1]
  def change
    create_table :activities do |t|
      t.string    :title,       null: false
      t.datetime  :start_time,  null: false
      t.datetime  :end_time,    null: false

      t.datetime :deleted_at
      t.timestamps
    end
  end
end
