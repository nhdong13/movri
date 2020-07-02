class CreateSlideItems < ActiveRecord::Migration[5.2]
  def change
    create_table :slide_items do |t|
      t.references :slideshow
      t.attachment :image
      t.string :heading
      t.string :sub_heading
      t.string :text_color, default: '#000'
      t.string :background_link
      t.integer :text_alignment, default: 0
      t.string :button_lable
      t.string :button_link
      t.timestamps
    end
  end
end
