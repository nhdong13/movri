class AddRedirectableToRedirectUrls < ActiveRecord::Migration[5.2]
  def change
    add_column :redirect_urls, :redirectable_id, :integer
    add_column :redirect_urls, :redirectable_type, :string
    add_index :redirect_urls, [:redirectable_id, :redirectable_id]
  end
end
