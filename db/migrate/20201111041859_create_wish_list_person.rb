class CreateWishListPerson < ActiveRecord::Migration[5.2]
  def change
    create_table :people_wish_lists, id: false do |t|
      t.string :person_id
      t.integer :listing_id
    end
  end
end
