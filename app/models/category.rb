# == Schema Information
#
# Table name: categories
#
#  id            :integer          not null, primary key
#  parent_id     :integer
#  icon          :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  community_id  :integer
#  sort_priority :integer
#  url           :string(255)
#  category_type :integer          default("category")
#  link          :string(255)
#  display_title :string(255)
#
# Indexes
#
#  index_categories_on_community_id  (community_id)
#  index_categories_on_parent_id     (parent_id)
#  index_categories_on_url           (url)
#

class Category < ApplicationRecord

  attr_accessor :basename

  has_many :subcategories,  :class_name => "Category", :foreign_key => "parent_id", :dependent => :destroy, :inverse_of => :parent
  # children is a more generic alias for sub categories, used in classification.rb
  has_many :children, :class_name => "Category", :foreign_key => "parent_id", :inverse_of => :parent
  belongs_to :parent, :class_name => "Category", touch: true
  has_many :listings, :dependent => :nullify
  has_many :category_listings, :dependent => :nullify
  has_many :translations, :class_name => "CategoryTranslation", :dependent => :destroy

  has_and_belongs_to_many :listing_shapes, -> { order("sort_priority") }, join_table: "category_listing_shapes"

  has_many :category_custom_fields, :dependent => :destroy
  has_many :custom_fields, -> { order("sort_priority") }, :through => :category_custom_fields

  belongs_to :community

  validates :url, uniqueness: true

  after_save :update_category_type
  before_destroy :can_be_destroyed?

  enum category_type: [:category, :subcategory, :children_category]
  # default_scope { includes([:children, :parent]) }

  def translation_attributes=(attributes)
    build_attrs = attributes.map { |locale, values| { locale: locale, values: values } }
    build_attrs.each do |translation|
      if existing_translation = translations.find_by_locale(translation[:locale])
        existing_translation.update(translation[:values])
      else
        translations.build(translation[:values].merge({:locale => translation[:locale]}))
      end
    end
  end

  def to_param
    url
  end

  def url_source
    basename || Maybe(default_translation_without_cache).name.or_else("category")
  end

  def default_translation_without_cache
    (translations.find { |translation| translation.locale == community.default_locale } || translations.first)
  end

  def display_name(locale)
    TranslationCache.new(self, :translations).translate(locale, :name)
  end

  def has_own_or_subcategory_listings?
    listings.count > 0 || subcategories.any? { |subcategory| !subcategory.listings.empty? }
  end

  def has_subcategories?
    subcategories.count > 0
  end

  def has_own_or_subcategory_custom_fields?
    custom_fields.count > 0 || subcategories.any? { |subcategory| !subcategory.custom_fields.empty? }
  end

  def subcategory_ids
    subcategories.collect(&:id)
  end

  def own_and_subcategory_ids
    [id].concat(subcategory_ids)
  end

  def is_subcategory?
    !parent_id.nil?
  end

  def can_destroy?
    is_subcategory? || community.top_level_categories.count > 1
  end

  def can_be_destroyed?
    throw :abort unless can_destroy?
  end

  def remove_needs_caution?
    has_own_or_subcategory_listings? or has_subcategories?
  end

  def own_and_subcategory_listings
    Listing.find_by_category_and_subcategory(self)
  end

  def own_and_subcategory_custom_fields
    CategoryCustomField.find_by_category_and_subcategory(self).includes(:custom_field).collect(&:custom_field)
  end

  def with_all_children
    # first add self
    child_array = [self]

    # Then add children with their children too
    children.each do |child|
      child_array << child.with_all_children
    end

    return child_array.flatten
  end

  def all_subcategories
    return [] unless self.category?
    subcategories.where(category_type: 1).order(sort_priority: :asc)
  end

  def all_children_categories
    return [] unless self.subcategory?
    children.where(category_type: 2).order(sort_priority: :asc)
  end

  def icon_name
    return icon if ApplicationHelper.icon_specified?(icon)
    return parent.icon_name if parent

    return "other"
  end

  def self.find_by_url_or_id(url_or_id)
    self.find_by_id(url_or_id) || self.find_by_url(url_or_id)
  end

  def url_name
    display_title&.split('-')&.join(' ')&.capitalize
  end

  def update_category_type
    if parent
      if parent.category?
        update_column(:category_type, 1)
      else parent.subcategory?
        update_column(:category_type, 2)
      end
    else
      update_column(:category_type, 0)
    end
  end
end
