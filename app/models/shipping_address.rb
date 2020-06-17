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

class ShippingAddress < ApplicationRecord
  belongs_to :tx, class_name: "Transaction", foreign_key: "transaction_id", inverse_of: :shipping_address
  validates_length_of :phone, :in => 10..16, :allow_nil => false

  before_save :convert_phone
  def convert_phone
    self.phone = phone.tr("(), ,-", "")
  end
end
