# == Schema Information
#
# Table name: pages
#
#  id           :bigint           not null, primary key
#  name         :string(255)
#  url          :string(255)      not null
#  community_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_pages_on_community_id  (community_id)
#  index_pages_on_url           (url)
#

class Page < ApplicationRecord
  validates :url, presence: true, uniqueness: true

  belongs_to :community
end
