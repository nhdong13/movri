class AddPaddingTimeToCommunity < ActiveRecord::Migration[5.2]
  def change
    add_column :communities, :padding_time_before, :float, default: 0.0
    add_column :communities, :padding_time_after, :float, default: 0.0
  end
end
