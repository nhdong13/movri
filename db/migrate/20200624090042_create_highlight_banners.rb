class CreateHighlightBanners < ActiveRecord::Migration[5.2]
  def change
    create_table :highlight_banners do |t|
      t.references :online_store
      t.boolean :enabled, default: true
      t.string :text_color, default: '#000'
      t.string :background_color, default: '#FFF'
      t.timestamps
    end
  end
end
