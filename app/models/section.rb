# == Schema Information
#
# Table name: sections
#
#  id               :bigint           not null, primary key
#  online_store_id  :integer
#  name             :string(255)
#  sectionable_id   :bigint
#  sectionable_type :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Section < ApplicationRecord
  
  DEFAULT_SECTIONS = %w(header slideshow highlight_banner).freeze
  belongs_to :sectionable, polymorphic: true
  scope :featured_products, -> { where(sectionable_type: 'StoreFeaturedProduct') }
  scope :categories_list, -> { where(sectionable_type: 'StoreCategory') }
  scope :store_grids, -> { where(sectionable_type: 'StoreGrid') }
  scope :store_footers, -> { where(sectionable_type: 'StoreFooter') }
  scope :helpful_links, -> { where(sectionable_type: 'HelpfulLink') }
  


  def as_json
    return {
      id: id, 
      name: name,
      object: sectionable.as_json
    }
  end
end
