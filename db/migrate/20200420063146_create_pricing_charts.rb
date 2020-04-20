class CreatePricingCharts < ActiveRecord::Migration[5.2]
  def change
    create_table :pricing_charts do |t|
      t.integer :listing_id
      t.integer :period
      t.float :price

      t.timestamps
    end
  end
end
