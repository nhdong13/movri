class AddCurrenciesToStoreFooterItem < ActiveRecord::Migration[5.2]
  def change
    add_column :store_footer_items, :currency, :json
  end
end
