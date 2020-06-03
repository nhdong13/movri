# == Schema Information
#
# Table name: promo_codes
#
#  id          :bigint           not null, primary key
#  code        :string(255)
#  expiry_date :date
#  quota       :integer
#  promo_type  :integer
#  unlimited   :boolean
#  active      :boolean
#  deleted     :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class PromoCode < ApplicationRecord
  enum promo_type: [:discount_10_percent, :discount_20_percent]
end
