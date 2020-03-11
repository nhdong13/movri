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

require 'rails_helper'

RSpec.describe PackingDimension, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
