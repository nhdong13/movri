class AddPreferenceColumnsToCommunityCustomizations < ActiveRecord::Migration[5.2]
  def change
    change_table :community_customizations do |t|
      t.text :general_colors
      t.text :button_colors
      t.text :footer_colors
      t.text :header_colors
      t.integer :base_font_size
      t.text :heading_font_settings
      t.text :button_font_settings
      t.text :main_menu_font_settings
      t.text :section_heading_font_settings
      t.attachment :social_media_image
      t.text :social_media_accounts
      t.attachment :favicon_icon
      t.text :currency_settings
    end
 
  end
end
