# == Schema Information
#
# Table name: store_grids
#
#  id                    :bigint           not null, primary key
#  online_store_id       :bigint
#  heading               :string(255)
#  height                :integer          default("small")
#  text_alignment        :integer          default("bottom_center")
#  maintain_aspect_ratio :boolean          default(FALSE)
#  compress_block        :boolean          default(FALSE)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_store_grids_on_online_store_id  (online_store_id)
#

class StoreGrid < ApplicationRecord
  include Sectionable

  has_many :store_grid_items, dependent: :destroy

  enum height: %w(small)
  enum text_alignment: %w(bottom_center top_center)

  def as_json
    super.merge(items: store_grid_items.as_json)
  end
end
