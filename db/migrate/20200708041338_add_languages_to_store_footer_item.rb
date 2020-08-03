class AddLanguagesToStoreFooterItem < ActiveRecord::Migration[5.2]
  def change
    add_column :store_footer_items, :languages, :json
  end
end
