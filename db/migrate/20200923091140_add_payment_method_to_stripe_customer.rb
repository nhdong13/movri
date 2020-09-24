class AddPaymentMethodToStripeCustomer < ActiveRecord::Migration[5.2]
  def change
    add_column :stripe_customers, :payment_method_id, :string
  end
end
