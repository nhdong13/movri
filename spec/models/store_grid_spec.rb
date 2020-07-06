# == Schema Information
#
# Table name: store_grids
#
#  id                    :bigint           not null, primary key
#  online_store_id       :bigint
#  heading               :string(255)
#  height                :integer          default(0)
#  text_alignment        :integer          default(0)
#  maintain_aspect_ratio :boolean          default(FALSE)
#  compress_block        :boolean          default(FALSE)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_store_grids_on_online_store_id  (online_store_id)
#

require 'rails_helper'

RSpec.describe StoreGrid, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
