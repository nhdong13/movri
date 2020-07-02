# == Schema Information
#
# Table name: store_featured_products
#
#  id                :bigint           not null, primary key
#  online_store_id   :bigint
#  heading           :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  button_text_color :string(255)      default("#fff")
#
# Indexes
#
#  index_store_featured_products_on_online_store_id  (online_store_id)
#

class StoreFeaturedProduct < ApplicationRecord
  has_many :store_featured_product_items, dependent: :destroy

  def as_json
    super.merge(selected_products: selected_products)
  end

  def product_ids
    store_featured_product_items.pluck :product_id
  end

  def product_ids=data
    ActiveRecord::Base.transaction do
      remove_ids = store_featured_product_items.where.not(product_id: data)
      create_ids = data - product_ids
      remove_ids.delete_all
      create_ids.each do |product_id|
        store_featured_product_items.create(product_id: product_id)
      end
    end 
  end
  
  def selected_products
    listings = Listing.where(id: product_ids)
    listings.map do |l|
      {value: l.id, label: l.title}
    end
  end

  def section
    Section.find_by(sectionable_id: self.id, sectionable_type: self.class.name)
  end
end
