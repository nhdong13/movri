class AddOnlineStoreIdtoSlideshow < ActiveRecord::Migration[5.2]
  def change
    add_column :slideshows, :online_store_id, :integer
    add_index :slideshows, :online_store_id
  end
end
