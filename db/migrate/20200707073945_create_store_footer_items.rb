class CreateStoreFooterItems < ActiveRecord::Migration[5.2]
  def change
    create_table :store_footer_items do |t|
      t.references :store_footer
      t.string :heading
      t.string :sub_heading
      t.text :text
      t.string :link
      t.timestamps
    end
  end
end
