# == Schema Information
#
# Table name: pricing_charts
#
#  id         :bigint           not null, primary key
#  listing_id :integer
#  period     :integer
#  price      :float(24)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PricingChart < ApplicationRecord
  belongs_to :listing
end
