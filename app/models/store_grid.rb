# == Schema Information
#
# Table name: store_grids
#
#  id                    :bigint           not null, primary key
#  online_store_id       :bigint
#  heading               :string(255)
#  height                :integer          default("small")
#  text_alignment        :integer          default("top_left")
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

  enum height: SECTION_GRID_OPTIONS[:heights].keys
  enum text_alignment: SECTION_GRID_OPTIONS[:text_alignments].keys
  enum width: SECTION_GRID_OPTIONS[:widths].keys

  def as_json
    super.merge(items: store_grid_items.order(order_number: :asc).as_json)
  end
end
  
