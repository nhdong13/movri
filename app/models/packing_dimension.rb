# == Schema Information
#
# Table name: packing_dimensions
#
#  id         :bigint           not null, primary key
#  height     :decimal(10, )
#  length     :decimal(10, )
#  width      :decimal(10, )
#  weight     :decimal(10, )
#  listing_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PackingDimension < ApplicationRecord
  belongs_to :listing

  validates :height, :length, :width, :weight, presence: true
end
