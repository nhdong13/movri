# == Schema Information
#
# Table name: padding_times
#
#  id         :bigint           not null, primary key
#  listing_id :integer
#  start_date :datetime
#  end_date   :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PaddingTime < ApplicationRecord
  belongs_to :listing
end
