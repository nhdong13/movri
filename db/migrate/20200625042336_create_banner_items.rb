class CreateBannerItems < ActiveRecord::Migration[5.2]
  def change
    create_table :banner_items do |t|
      t.references :highlight_banner
      t.attachment :image
      t.string :heading
      t.string :sub_heading
      t.text :text
      t.string :link
      t.timestamps
    end
  end
end
