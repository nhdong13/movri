# == Schema Information
#
# Table name: slideshows
#
#  id             :bigint           not null, primary key
#  header_id      :integer
#  enabled        :boolean          default(TRUE)
#  auto_play      :boolean          default(TRUE)
#  slide_duration :integer          default(8)
#  slide_height   :integer          default(0)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_slideshows_on_header_id  (header_id)
#

class Slideshow < ApplicationRecord
  belongs_to :header
end
