# == Schema Information
#
# Table name: listing_details
#
#  id                 :bigint           not null, primary key
#  spec               :text(65535)
#  overview           :text(65535)
#  q_a                :text(65535)
#  in_the_box         :text(65535)
#  not_in_the_box     :text(65535)
#  key_feature        :text(65535)
#  available_quantity :integer
#  sku                :string(255)
#  barcode            :string(255)
#  track_quantity     :boolean
#  contiunue_sell     :boolean
#  user_manual        :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class ListingDetail < ApplicationRecord
end
