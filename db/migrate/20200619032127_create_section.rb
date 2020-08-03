class CreateSection < ActiveRecord::Migration[5.2]
  def change
    create_table :sections do |t|
      t.integer :online_store_id
      t.string :name
      t.bigint  :sectionable_id
      t.string  :sectionable_type
      t.timestamps
    end
  end
end
