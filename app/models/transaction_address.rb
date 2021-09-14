# == Schema Information
#
# Table name: transaction_addresses
#
#  id                       :integer          not null, primary key
#  status                   :string(255)
#  phone                    :string(255)
#  postal_code              :string(255)
#  city                     :string(255)
#  country                  :string(255)
#  state_or_province        :string(255)
#  street1                  :string(255)
#  street2                  :string(255)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  country_code             :string(8)
#  person_id                :string(255)
#  first_name               :string(255)
#  last_name                :string(255)
#  company                  :string(255)
#  apartment                :string(255)
#  email                    :string(255)
#  is_office_address        :boolean          default(FALSE)
#  address_type             :integer          default("shipping_address")
#  is_deleted               :boolean          default(FALSE)
#  deleted_at               :datetime
#  office_state_or_province :string(255)
#  office_postal_code       :string(255)
#  office_street1           :string(255)
#  office_city              :string(255)
#

class TransactionAddress < ApplicationRecord
  belongs_to :person
  has_many :transactions
  validates_length_of :phone, :in => 10..16, :allow_nil => false, unless: :is_office_address?

  before_save :convert_phone
  before_save :convert_postal_code
  before_create :add_country

  before_create :add_office_address

  validate :change_office_address, on: :update
  validates :state_or_province, presence: true, allow_blank: false, unless: :is_office_address?

  enum address_type: [:shipping_address, :billing_address]

  default_scope { where(is_deleted: false) }
  scope :deleted, -> { unscope(:where).where(is_deleted: true) }

  def add_office_address
    self.office_state_or_province = OFFICE_ADDRESS[:state_or_province]
    self.office_postal_code = OFFICE_ADDRESS[:postal_code]
    self.office_street1 = OFFICE_ADDRESS[:street1]
    self.office_city = OFFICE_ADDRESS[:city]
  end

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

  def convert_postal_code
    return unless self.postal_code
    self.postal_code = postal_code.split(" ").join("")
  end
  
  def enable_office_address
    update(is_office_address: true)  
  end

  def disable_office_address
    update(is_office_address: false)  
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
    if is_office_address?
      "#{office_street1}, #{office_city}, #{CANADA_PROVINCES.key(office_state_or_province)}, #{country}, #{office_postal_code}"
    else
      "#{street1}, #{city}, #{CANADA_PROVINCES.key(state_or_province)}, #{country}, #{postal_code}"
    end
  end

  def fullname
    return "" unless first_name && last_name
    first_name.capitalize + " " + last_name.capitalize
  end

  def format_phone
    return unless phone
    phone_arr = phone.split("")
    "(#{phone_arr[0..2].join()}) #{phone_arr[3..5].join()}-#{phone_arr[6..9].join()}"
  end

  def format_postal_code
    if is_office_address?
      return unless office_postal_code.present? 
      code_arr = office_postal_code.split("")
    else
      return unless postal_code.present?
      code_arr = postal_code.split("")
    end
    "#{code_arr[0..2].join()} #{code_arr[3..5].join()}"
  end

  def get_street1
    is_office_address? ? office_street1 : street1 
  end

  def get_city
    is_office_address? ? office_city : city 
  end

  def get_state_or_province
    is_office_address? ? office_state_or_province : state_or_province 
  end

  def get_postal_code
    is_office_address? ? office_postal_code : postal_code 
  end
end
