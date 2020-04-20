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

require 'rails_helper'

RSpec.describe PricingChart, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
