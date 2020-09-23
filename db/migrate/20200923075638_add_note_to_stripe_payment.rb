class AddNoteToStripePayment < ActiveRecord::Migration[5.2]
  def change
    add_column :stripe_payments, :payment_type, :integer, default: 0
    add_column :stripe_payments, :note, :string
  end
end
