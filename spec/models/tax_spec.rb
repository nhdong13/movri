# == Schema Information
#
# Table name: taxes
#
#  id               :bigint           not null, primary key
#  province         :string(255)
#  province_display :string(255)
#  tax_rates        :text(65535)
#  community_id     :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_taxes_on_community_id  (community_id)
#

require 'rails_helper'

RSpec.describe Tax, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
