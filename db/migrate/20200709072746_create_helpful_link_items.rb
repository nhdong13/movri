class CreateHelpfulLinkItems < ActiveRecord::Migration[5.2]
  def change
    create_table :helpful_link_items do |t|
      t.references :helpful_link
      t.string :heading
      t.boolean :enabled, default: false
      t.string :text
      t.string :heading_color, default: '#334455'
      t.string :text_color, default: '#999'
      t.integer :content_type, default: 0
      t.timestamps
    end
  end
end
