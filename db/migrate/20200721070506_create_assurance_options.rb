class CreateAssuranceOptions < ActiveRecord::Migration[5.2]
  def change
    create_table :assurance_options do |t|
      t.string :title
      t.text :content
      t.boolean :visible, default: false
      t.attachment :image
      t.integer :community_id

      t.timestamps
    end

    add_index :assurance_options, :community_id
  end
end
