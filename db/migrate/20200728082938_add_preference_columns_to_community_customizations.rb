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
      t.text :body_text_font_settings
      t.attachment :social_media_image
      t.text :social_media_accounts
      t.text :currency_settings
    end

    CommunityCustomization.all.update_all(
      general_colors: {"background"=> "#f0f0f0", "headings"=> "#000000", "text"=> "#000000", "links"=> "#4a90e2"},
      button_colors: {"background"=> "#4a90e2", "text"=> "#FFFFFF"},
      header_colors: {"background"=> "#e8e9ea", "text"=> "#707070"},
      footer_colors: {"background"=> "#959595", "text"=> "#3c3c3c"},
      base_font_size: 16,
      heading_font_settings: {"font_family"=> "Source Sans Pro", "font_weight"=> "medium", "uppercase"=> false, "letter_spacing"=> 0},
      button_font_settings: {"font_family"=> "Source Sans Pro", "uppercase"=> false, "letter_spacing"=> 0},
      main_menu_font_settings: {"font_family"=> "Source Sans Pro", "uppercase"=> false, "letter_spacing"=> 0},
      body_text_font_settings: {"font_family"=> "Source Sans Pro", "uppercase"=> false, "letter_spacing"=> 0},
      section_heading_font_settings: {"font_family"=> "Source Sans Pro", "uppercase"=> false, "letter_spacing"=> 0},
    )
    
  end
end
