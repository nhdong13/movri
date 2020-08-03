class FixIndexesOnRedirectUrls < ActiveRecord::Migration[5.2]
  def change
    remove_index :redirect_urls, [:redirectable_id]
    add_index :redirect_urls, [:redirectable_id, :redirectable_type]
  end
end
