class ChangeColumnEmail < ActiveRecord::Migration[5.2]
  def change
    change_column :emails, :community_id, :integer, null: true
  end
end
