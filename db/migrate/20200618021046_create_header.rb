class CreateHeader < ActiveRecord::Migration[5.2]
  def change
    create_table :headers do |t|
      t.integer :online_store_id
      t.boolean :sticky_enabled, default: true
      t.attachment :logo
      t.boolean :announcement_enabled, default: false
      t.boolean :home_only_enabled, default: true
      t.string :title
      t.string :link
      t.string :text_color, default: '#FFF'
      t.string :background_color, default: '#FF0000'

      t.timestamps
    end

    add_index :headers, :online_store_id
  end
end
