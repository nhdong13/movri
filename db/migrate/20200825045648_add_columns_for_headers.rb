class AddColumnsForHeaders < ActiveRecord::Migration[5.2]
  def change
    add_column :headers, :tag_line_setting, :text
    add_column :headers, :phone_number_setting, :text
    add_column :headers, :contact_us_setting, :text
    add_column :headers, :faq_setting, :text
    add_column :headers, :announcement_bar_setting, :text

    Header.all.each do |header|
      announcement_bar_setting = {
        "enabled" => header.announcement_enabled,
        "home_only_enabled" => header.home_only_enabled,
        "text" => "<p>#{header.title}</p>\n",
        "link" => header.link,
        "text_color" => header.text_color,
        "background_color" => header.background_color
      }
      tag_line_setting = {"enabled"=>true, "home_only_enabled"=>false, "text"=>"<p><strong>The Professional&#39;s Source&nbsp;</strong>Since 1973</p>\n", "text_color"=>"#7a9f5c", "background_color"=>"#e8e9ea"}
      phone_number_setting = {"phone_number"=>"800.606.6969", "link"=>"tel:8006066969", "text_color"=>"#959698", "background_color"=>"#e8e9ea"}
      contact_us_setting = {"text"=>"<p><strong>Contact Us</strong></p>\n", "link"=>"/", "text_color"=>"#959698", "background_color"=>"#e8e9ea"}
      faq_setting = {"text"=>"<p><strong>FAQ</strong></p>\n", "link"=>"/", "text_color"=>"#959698", "background_color"=>"#e8e9ea"}

      header.update(
        announcement_bar_setting: announcement_bar_setting,
        tag_line_setting: tag_line_setting,
        phone_number_setting: phone_number_setting,
        contact_us_setting: contact_us_setting,
        faq_setting: faq_setting,
      )
    end
  end
end
