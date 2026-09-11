class AddArchivedAtToPriceList < ActiveRecord::Migration[7.0]
  def change
    add_column :price_lists, :archived_at, :datetime
  end
end
