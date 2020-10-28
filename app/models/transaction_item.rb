# == Schema Information
#
# Table name: transaction_items
#
#  id                    :bigint           not null, primary key
#  transaction_id        :integer
#  listing_id            :integer
#  listing_uuid          :binary(16)
#  listing_title         :integer
#  quantity              :integer
#  coverage_price_cents  :integer
#  price_cents           :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  is_deleted            :boolean          default(FALSE)
#  deleted_at            :datetime
#  note                  :string(255)
#  replacement_cents_fee :integer          default(0)
#

class TransactionItem < ApplicationRecord
  belongs_to :listing
  belongs_to :tx, class_name: 'Transaction', foreign_key: "transaction_id"
  validates :quantity, numericality: {only_integer: true, greater_than_or_equal_to: 1}, on: :create
  validates :listing_title, presence: true, on: :create

  default_scope { where(is_deleted: false) }
  scope :deleted, -> { unscope(:where).where(is_deleted: true) }

  def soft_delete
    update(is_deleted: true, deleted_at: DateTime.now)
  end

  def restore
    update(is_deleted: false, deleted_at: nil)
  end

  def price_cents_to_CAD
    price_cents.to_f / 100
  end
end
