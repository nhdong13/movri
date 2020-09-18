class AddMoreColumnsToPromoCode < ActiveRecord::Migration[5.2]
  def change
    add_column :promo_codes, :fixed_amount_cents_value, :integer, default: 0
    add_column :promo_codes, :discount_value, :integer, default: 0
    add_column :promo_codes, :applies_to, :integer, default: 0
    add_column :promo_codes, :limit_collection_ids, :string
    add_column :promo_codes, :limit_product_ids, :string
    add_column :promo_codes, :minimum_requirements, :integer, default: 0
    add_column :promo_codes, :minimum_quantity_value, :integer, default: 0
    add_column :promo_codes, :minimum_purchase_amount_cents_value, :integer
    add_column :promo_codes, :customer_eligibility, :integer, default: 0
    add_column :promo_codes, :limit_person_ids, :string
    add_column :promo_codes, :is_usage_limit_number, :boolean, default: false
    add_column :promo_codes, :usage_limit_number, :integer
    add_column :promo_codes, :is_usage_limit_one_per_person, :boolean, default: false
    add_column :promo_codes, :start_datetime, :datetime
    add_column :promo_codes, :end_datetime, :datetime
    add_column :promo_codes, :number_of_uses, :integer, default: 0
  end
end
