class AddManuallyBlockedDatesToListings < ActiveRecord::Migration[5.2]
  def change
    add_column :listings, :manually_blocked_dates, :text
  end
end
