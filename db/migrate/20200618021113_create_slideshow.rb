class CreateSlideshow < ActiveRecord::Migration[5.2]
  def change
    create_table :slideshows do |t|
      t.integer :header_id
      t.boolean :enabled, default: true
      t.boolean :auto_play, default: true
      t.integer :slide_duration, default: 8
      t.integer :slide_height, default: 0

      t.timestamps
    end
    add_index :slideshows, :header_id
  end
end
