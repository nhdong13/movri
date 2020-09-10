class AddTaxAccountsToCommunities < ActiveRecord::Migration[5.2]
  def change
    add_column :communities, :tax_accounts, :json
  end
end
