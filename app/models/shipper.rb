# == Schema Information
#
# Table name: shippers
#
#  id               :bigint           not null, primary key
#  transaction_id   :integer
#  service_delivery :string(255)
#  service_type     :string(255)
#  service_name     :string(255)
#  amount           :float(24)
#  currency         :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Shipper < ApplicationRecord
  belongs_to :tx, class_name: "Transaction", foreign_key: "transaction_id"

  def amount_to_cents
    amount * CONVERT_TO_CENT_VALUE
  end

  def fedex?
    service_delivery == "fedex"
  end

  def ups?
    service_delivery == "ups"
  end
end
