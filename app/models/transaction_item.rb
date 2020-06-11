# == Schema Information
#
# Table name: transaction_items
#
#  id                   :bigint           not null, primary key
#  transaction_id       :integer
#  listing_id           :integer
#  listing_uuid         :binary(16)
#  listing_title        :integer
#  quantity             :integer
#  coverage_price_cents :integer
#  price_cents          :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

class TransactionItem < ApplicationRecord
  belongs_to :listing
  belongs_to :tx, class_name: 'Transaction', foreign_key: "transaction_id"
  validates :quantity, numericality: {only_integer: true, greater_than_or_equal_to: 1}, on: :create
  validates :listing_title, presence: true, on: :create
end
