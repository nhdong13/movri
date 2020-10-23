# == Schema Information
#
# Table name: custom_items
#
#  id               :bigint           not null, primary key
#  transaction_id   :integer
#  name             :string(255)
#  price_cents      :float(24)        default(0.0)
#  quantity         :integer
#  discount_percent :integer          default(0)
#  discount_value   :integer          default(0)
#  note             :string(255)
#  custom_item_type :integer          default("is_listing")
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class CustomItem < ApplicationRecord
  belongs_to :tx, class_name: 'Transaction'
  enum custom_item_type: [:is_listing, :is_discount, :is_shipping_fee]

end
