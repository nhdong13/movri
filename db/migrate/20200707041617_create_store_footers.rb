class CreateStoreFooters < ActiveRecord::Migration[5.2]
  def change
    create_table :store_footers do |t|
      t.references :online_store
      t.string :name
      t.boolean :enabled, default: false
      t.string :text_color, default: '#000'
      t.string :background_color, default: '#fff'
      t.timestamps
    end
  end
end
