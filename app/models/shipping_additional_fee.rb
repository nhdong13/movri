# == Schema Information
#
# Table name: shipping_additional_fees
#
#  id         :bigint           not null, primary key
#  handling   :float(24)        default(0.0)
#  insurance  :float(24)        default(0.0)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ShippingAdditionalFee < ApplicationRecord
end
