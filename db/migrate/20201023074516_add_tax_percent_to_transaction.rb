class AddTaxPercentToTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :tax_percent, :integer, default: 0
  end
end
