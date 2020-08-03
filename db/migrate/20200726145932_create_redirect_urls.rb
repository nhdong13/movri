class CreateRedirectUrls < ActiveRecord::Migration[5.2]
  def change
    create_table :redirect_urls do |t|
      t.string :from
      t.string :to
      t.integer :community_id

      t.timestamps
    end

    add_index :redirect_urls, :community_id
  end
end
