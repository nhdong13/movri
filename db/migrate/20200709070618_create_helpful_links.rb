class CreateHelpfulLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :helpful_links do |t|
      t.references :online_store
      t.string :heading
      t.integer :content_type

      t.timestamps
    end
  end
end
