class CreateStripeCustomers < ActiveRecord::Migration[5.2]
  def change
    create_table :stripe_customers do |t|
      t.integer :transaction_id
      t.string :person_id
      t.string :stripe_customer_id
      t.timestamps
    end
  end
end
