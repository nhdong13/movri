class AddShippingRatesContentToCommunity < ActiveRecord::Migration[5.2]
  def change
    add_column :communities, :shipping_rates_content, :text
    add_column :communities, :pricing_chart_content, :text
  end
end
