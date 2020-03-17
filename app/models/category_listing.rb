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

class CategoryListing < ApplicationRecord
  belongs_to :category
  belongs_to :listing
end
