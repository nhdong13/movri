class CreateTabelPromoCodeUsedPeople < ActiveRecord::Migration[5.2]
  def change
    create_table :people_promo_codes, id: false do |t|
      t.string :person_id, null: false
      t.integer :promo_code_id, null: false
      t.timestamps
    end
  end
end
