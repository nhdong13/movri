# == Schema Information
#
# Table name: stripe_customers
#
#  id                 :bigint           not null, primary key
#  transaction_id     :integer
#  person_id          :string(255)
#  stripe_customer_id :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  payment_method_id  :string(255)
#

class StripeCustomer < ApplicationRecord
  belongs_to :person, optional: true
  belongs_to :tx, class_name: 'Transaction', foreign_key: "transaction_id", optional: true
  validates_presence_of :stripe_customer_id
  validates_presence_of :payment_method_id
end
