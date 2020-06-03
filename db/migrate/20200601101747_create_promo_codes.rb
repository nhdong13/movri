class CreatePromoCodes < ActiveRecord::Migration[5.2]
  def change
    create_table :promo_codes do |t|
      t.string :code
      t.date :expiry_date
      t.integer :quota
      t.integer :promo_type
      t.boolean :unlimited
      t.boolean :active
      t.boolean :deleted
      t.timestamps
    end
  end
end
