class RemoveColumnsOutOfTransaction < ActiveRecord::Migration[5.2]
  def change
    change_column :transactions, :starter_id, :string, null: true
    change_column :transactions, :starter_uuid, :string, null: true
    change_column :transactions, :automatic_confirmation_after_days, :string, null: true
    change_column :transactions, :community_id, :string, null: true
    change_column :transactions, :community_uuid, :string, null: true
    change_column :transactions, :unit_price_cents, :integer  , null: true
    add_column :transactions, :uuid, :binary, limit: 16, null: false
    add_column :transactions, :instructions_from_seller, :text
    add_column :transactions, :promo_code_id, :integer
    add_column :transactions, :total_price_cents, :integer
    add_column :transactions, :tax_cents, :integer
    add_column :transactions, :promo_code_discount_cents, :integer
    remove_column :transactions, :listing_id
    remove_column :transactions, :listing_uuid
    remove_column :transactions, :listing_author_id
    remove_column :transactions, :commission_from_seller
    remove_column :transactions, :minimum_commission_cents
    remove_column :transactions, :minimum_commission_currency
    remove_column :transactions, :listing_quantity
    remove_column :transactions, :listing_author_uuid
    remove_column :transactions, :listing_title
    remove_column :transactions, :commission_from_buyer
    remove_column :transactions, :minimum_buyer_fee_cents
    remove_column :transactions, :minimum_buyer_fee_currency
  end
end
