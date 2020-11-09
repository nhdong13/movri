# == Schema Information
#
# Table name: transaction_addresses
#
#  id                :integer          not null, primary key
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
#  person_id         :string(255)
#  first_name        :string(255)
#  last_name         :string(255)
#  company           :string(255)
#  apartment         :string(255)
#  email             :string(255)
#  is_office_address :boolean          default(FALSE)
#  address_type      :integer          default("shipping_address")
#  is_deleted        :boolean          default(FALSE)
#  deleted_at        :datetime
#

class TransactionAddress < ApplicationRecord
  belongs_to :person
  has_many :transactions
  validates_length_of :phone, :in => 10..16, :allow_nil => false, unless: :is_office_address?

  before_save :convert_phone
  before_create :add_country

  validate :change_office_address, on: :update

  enum address_type: [:shipping_address, :billing_address]

  default_scope { where(is_deleted: false) }
  scope :deleted, -> { unscope(:where).where(is_deleted: true) }

  def soft_delete
    update(is_deleted: true, deleted_at: DateTime.now)
  end

  def restore
    update(is_deleted: false, deleted_at: nil)
  end

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

  def full_address
    "#{street1}, #{city}, #{CANADA_PROVINCES.key(state_or_province)}, #{country}, #{postal_code} "
  end

  def fullname
    return "" unless first_name && last_name
    first_name.capitalize + " " + last_name.capitalize
  end

  def format_phone
    return unless phone
    phone_arr = phone.split("")
    "#{phone_arr[0]} (#{phone_arr[1..3].join()}) #{phone_arr[4..6].join()}-#{phone_arr[7..10].join()}"
  end

  def format_phone_v2
    return unless phone
    phone_arr = phone.split("")
    "(#{phone_arr[0..2].join()}) #{phone_arr[3..5].join()}-#{phone_arr[6..9].join()}"
  end
end
