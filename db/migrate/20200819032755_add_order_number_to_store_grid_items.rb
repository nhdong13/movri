class AddOrderNumberToStoreGridItems < ActiveRecord::Migration[5.2]
  def change
    add_column :store_grid_items, :order_number, :integer

    StoreGrid.all.each do |store_grid|
      i = 1
      store_grid.store_grid_items.each do |item|
        item.update(order_number: i)
        i += 1
      end
    end
  end
end
