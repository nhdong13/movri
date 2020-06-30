# == Schema Information
#
# Table name: shipping_addresses
#
#  id                :integer          not null, primary key
#  transaction_id    :integer          not null
#  status            :string(255)
#  phone             :string(255)
#  postal_code       :string(255)
#  city              :string(255)
#  country           :string(255)
#  state_or_province :string(255)
#  street1           :string(255)
#  street2           :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  country_code      :string(8)
#  person_id         :integer
#  first_name        :string(255)
#  last_name         :string(255)
#  company           :string(255)
#  apartment         :string(255)
#  email             :string(255)
#  is_office_address :boolean          default(FALSE)
#
# Indexes
#
#  index_shipping_addresses_on_transaction_id  (transaction_id)
#

class TransactionAddress < ApplicationRecord
  belongs_to :tx, class_name: "Transaction", foreign_key: "transaction_id", inverse_of: :transaction_addresses
  belongs_to :person
  validates_length_of :phone, :in => 10..16, :allow_nil => false, unless: :is_office_address?

  before_save :convert_phone
  before_create :add_country

  validate :change_office_address, on: :update
  validate :limit_of_transaction_address, on: :create

  enum address_type: [:shipping_address, :billing_address]

  def add_country
    self.country = 'Canada'
  end

  def convert_phone
    return unless self.phone
    self.phone = phone.tr("(), ,-", "")
  end

  def is_office_address?
    self.is_office_address
  end

  def change_office_address
    if is_office_address?
     if postal_code_changed? || city_changed? || country_changed? || state_or_province_changed? || street1_changed?
        errors.add(:shipping_address, "you cannot change office address")
      end
    end
  end

  def limit_of_transaction_address
    if tx && tx.transaction_addresses.size > 2
      errors.add(:transaction, 'can only have 2 transaction address: shipping and billing address')
    end
  end

  def full_address
    "#{street1}, #{city}, #{CANADA_PROVINCES.key(state_or_province)}, #{country}, #{postal_code} "
  end

  def fullname
    first_name + " " + last_name
  end
end
