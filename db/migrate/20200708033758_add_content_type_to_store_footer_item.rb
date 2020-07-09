class AddContentTypeToStoreFooterItem < ActiveRecord::Migration[5.2]
  def change
    add_column :store_footer_items, :content_type, :integer, default: 0
  end
end
