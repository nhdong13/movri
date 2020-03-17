# == Schema Information
#
# Table name: category_listings
#
#  id          :bigint           not null, primary key
#  category_id :integer
#  listing_id  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'rails_helper'

RSpec.describe CategoryListing, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
