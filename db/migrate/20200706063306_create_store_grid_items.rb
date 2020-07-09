class CreateStoreGridItems < ActiveRecord::Migration[5.2]
  def change
    create_table :store_grid_items do |t|
      t.references :store_grid
      t.string :heading
      t.attachment :image
      t.text :text
      t.string :text_color, default: '#000'
      t.string :link
      t.string :button_text
      t.integer :button_style, default: 0
      t.integer :width, default: 0
      t.timestamps
    end
  end
end
