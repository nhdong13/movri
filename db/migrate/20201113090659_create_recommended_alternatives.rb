class CreateRecommendedAlternatives < ActiveRecord::Migration[5.2]
  def change
    create_table :recommended_alternatives do |t|
      t.integer :listing_alternative_id
      t.integer :listing_id
      t.integer :position
      t.timestamps
    end
  end
end
