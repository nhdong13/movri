class CreateShippingAdditionalFees < ActiveRecord::Migration[5.2]
  def change
    create_table :shipping_additional_fees do |t|
      t.float :handling, default: 0
      t.float :insurance, default: 0
      t.timestamps
    end
  end
end
