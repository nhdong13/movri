class CreateOnlineStore < ActiveRecord::Migration[5.2]
  def change
    create_table :online_stores do |t|
      t.integer :community_id
      t.timestamps
    end

    add_index :online_stores, :community_id
  end
end
