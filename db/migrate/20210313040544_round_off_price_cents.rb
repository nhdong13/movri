class RoundOffPriceCents < ActiveRecord::Migration[5.2]
  def change
    change_column :custom_items, :price_cents, :decimal, :precision => 10, :scale => 2
    change_column :transactions, :tax_percent, :decimal, :precision => 10, :scale => 2
  end
end
