class Admin::PreferenceSettingsService

  def update_preferences community, params
    community.update(facebook_pixel_id: params.delete(:facebook_pixel_id))
      
    preferences = community.community_customizations.find(params[:id])

    preferences.favicon_icon = params[:favicon_icon] if params[:favicon_icon]
    preferences.social_media_image = params[:social_media_image] if params[:social_media_image]
    preferences.base_font_size = params[:base_font_size] if params[:base_font_size]
    preferences.general_colors = JSON.parse(params[:general_colors]) if params[:general_colors]
    preferences.button_colors = JSON.parse(params[:button_colors]) if params[:button_colors]
    preferences.footer_colors = JSON.parse(params[:footer_colors]) if params[:footer_colors]
    preferences.header_colors = JSON.parse(params[:header_colors]) if params[:header_colors]
    preferences.heading_font_settings = JSON.parse(params[:heading_font_settings]) if params[:heading_font_settings]
    preferences.button_font_settings = JSON.parse(params[:button_font_settings]) if params[:button_font_settings]
    preferences.main_menu_font_settings = JSON.parse(params[:main_menu_font_settings]) if params[:main_menu_font_settings]
    preferences.section_heading_font_settings = JSON.parse(params[:section_heading_font_settings]) if params[:section_heading_font_settings]
    preferences.social_media_accounts = JSON.parse(params[:social_media_accounts]) if params[:social_media_accounts]
    preferences.currency_settings = JSON.parse(params[:currency_settings]) if params[:currency_settings]
    preferences.body_text_font_settings = JSON.parse(params[:body_text_font_settings]) if params[:body_text_font_settings]
  
    preferences.save
  end

end