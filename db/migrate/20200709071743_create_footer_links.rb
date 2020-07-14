class CreateFooterLinks < ActiveRecord::Migration[5.2]
  def change
    create_table :footer_links do |t|
      t.references :helpful_link_item
      t.string :sub_heading
      t.string :link

      t.timestamps
    end
  end
end
