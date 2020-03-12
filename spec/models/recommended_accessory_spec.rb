# == Schema Information
#
# Table name: recommended_accessories
#
#  id                   :bigint           not null, primary key
#  listing_accessory_id :integer
#  listing_id           :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  position             :integer
#

require 'rails_helper'

RSpec.describe RecommendedAccessory, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
