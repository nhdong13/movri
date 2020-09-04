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
#  order_number     :integer
#

class Section < ApplicationRecord
  
  DEFAULT_SECTIONS = %w(header slideshow highlight_banner).freeze
  belongs_to :sectionable, polymorphic: true
  scope :featured_products, -> { where(sectionable_type: 'StoreFeaturedProduct') }
  scope :categories_list, -> { where(sectionable_type: 'StoreCategory') }
  scope :store_grids, -> { where(sectionable_type: 'StoreGrid') }
  scope :store_footers, -> { where(sectionable_type: 'StoreFooter') }
  scope :helpful_links, -> { where(sectionable_type: 'HelpfulLink') }
  scope :body_sections, -> { where.not(sectionable_type: ['StoreFooter', 'HelpfulLink', 'Header', 'Slideshow', 'HighlightBanner'])}
  scope :footer_sections, -> { where(sectionable_type: ['StoreFooter', 'HelpfulLink'])}

  before_create :set_order_number
  after_destroy :re_order_items

  def as_json
    return {
      id: id, 
      name: name,
      order_number: order_number,
      object: sectionable.as_json
    }
  end

  private

  def set_order_number
    if ['StoreFooter', 'HelpfulLink', 'Header', 'Slideshow', 'HighlightBanner'].exclude? self.sectionable_type
      self.order_number = Section.body_sections.where(online_store_id: online_store_id).size + 1
    elsif ['StoreFooter', 'HelpfulLink'].include? self.sectionable_type
      self.order_number = Section.footer_sections.where(online_store_id: online_store_id).size + 1
    end
  end

  def re_order_items
    if Section.body_sections.include?(self)
      Section.body_sections.where(online_store_id: online_store_id)
             .order(order_number: :asc)
             .each_with_index{ |item, index| item.update(order_number: index+1) }
    elsif Section.footer_sections.include?(self)
      Section.footer_sections.where(online_store_id: online_store_id)
             .order(order_number: :asc)
             .each_with_index{ |item, index| item.update(order_number: index+1) }
    end
  end
end
