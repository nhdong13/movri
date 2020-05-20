class AddGlobalBlockedDatesToCommunity < ActiveRecord::Migration[5.2]
  def change
    add_column :communities, :global_blocked_dates, :string
  end
end
