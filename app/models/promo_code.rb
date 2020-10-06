# == Schema Information
#
# Table name: promo_codes
#
#  id                                  :bigint           not null, primary key
#  code                                :string(255)
#  expiry_date                         :date
#  quota                               :integer
#  promo_type                          :integer
#  unlimited                           :boolean
#  active                              :boolean
#  deleted                             :boolean
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  fixed_amount_cents_value            :integer          default(0)
#  discount_value                      :integer          default(0)
#  applies_to                          :integer          default("all_order")
#  limit_collection_ids                :string(255)
#  limit_product_ids                   :string(255)
#  minimum_requirements                :integer          default("no_requirements")
#  minimum_quantity_value              :integer          default(0)
#  minimum_purchase_amount_cents_value :integer          default(0)
#  customer_eligibility                :integer          default("everyone")
#  limit_person_ids                    :string(255)
#  is_usage_limit_number               :boolean          default(FALSE)
#  usage_limit_number                  :integer
#  is_usage_limit_one_per_person       :boolean          default(FALSE)
#  start_datetime                      :datetime
#  end_datetime                        :datetime
#  number_of_uses                      :integer          default(0)
#

class PromoCode < ApplicationRecord
  enum promo_type: [:percentage, :fixed_amount, :free_shipping, :buy_x_get_y]
  enum applies_to: [:all_order, :specific_collections, :specific_products]
  enum minimum_requirements: [:no_requirements, :minimum_purchase_amount, :minimum_quantity]
  enum customer_eligibility: [:everyone, :specific_groups, :specific_customers]

  serialize :limit_person_ids
  serialize :limit_product_ids
  serialize :limit_collection_ids

  validates_presence_of :start_datetime

  has_many :tx, class_name: 'Transaction', :dependent => :destroy
  has_and_belongs_to_many :people
  validates_presence_of :start_datetime

  include AlgoliaSearch
  algoliasearch index_name: "movri_promo_codes" do
    attribute :id, :code, :number_of_uses
    attributes :active do
      still_active? ? "Active" : 'Expired'
    end
    attributes :start_datetime do
      get_start_date
    end
    attributes :end_datetime do
      get_end_date
    end
    attributes :desc do
      if percentage?
        "#{discount_value}% off #{applies_to} - For #{get_people_limit_name}"
      elsif fixed_amount?
        "Discount CA$#{fixed_amount_cents_value} #{applies_to} - For #{get_people_limit_name}"
      end
    end
  end

  def get_people_limit_name
    if specific_customers?
      people = Person.where(id: limit_person_ids)
      list_name = []
      people.map {|p| list_name.push(p.fullname)}
      list_name.join(", ")
    elsif specific_groups?
      "everyone"
    else
      "everyone"
    end
  end

  def get_start_time
    return unless start_datetime
    start_datetime.strftime("%H:%M")
  end

  def get_start_date
    return "--" unless start_datetime
    start_datetime.strftime("%Y-%m-%d")
  end

  def get_end_time
    return unless end_datetime
    end_datetime.strftime("%H:%M")
  end

  def get_end_date
    return "--" unless end_datetime
    end_datetime.strftime("%Y-%m-%d")
  end

  def fixed_amount_cents_value=(fixed_amount_cents_value)
    write_attribute(:fixed_amount_cents_value, fixed_amount_cents_value.to_i * 100)
  end

  def minimum_purchase_amount_cents_value=(minimum_purchase_amount_cents_value)
    write_attribute(:minimum_purchase_amount_cents_value, minimum_purchase_amount_cents_value.to_i * 100)
  end

  def still_active?
    return false if start_datetime.nil? || end_datetime.nil?
    is_active = false
    current_datetime = DateTime.now
    if end_datetime
      if start_datetime < current_datetime && end_datetime > current_datetime
        is_active = true
      end
    else
      is_active = true if start_datetime < current_datetime
    end
  end

  def unlimited_of_use?
    if is_usage_limit_number
      number_of_uses < usage_limit_number
    else
      true
    end
  end

  def can_use?
    still_active? || unlimited_of_use?
  end
end
