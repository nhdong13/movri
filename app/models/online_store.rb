# == Schema Information
#
# Table name: online_stores
#
#  id           :bigint           not null, primary key
#  community_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_online_stores_on_community_id  (community_id)
#

class OnlineStore < ApplicationRecord
  belongs_to :community
  has_one :header, dependent: :destroy
end
