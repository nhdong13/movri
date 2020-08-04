class Admin::CommunityPreferencesController < Admin::AdminBaseController
  before_action :set_selected_left_navi_link

  def edit
    @preferences = @current_community.community_customizations.where(locale: locale).first
  end

  def update
    @preferences = Admin::PreferenceSettingsService.new.update_preferences(@current_community, preferences_params)
  end

  private

  def set_selected_left_navi_link
    @selected_left_navi_link = "customers"
  end

  def preferences_params
    params.required(:preferences).permit(
      :id,
      :facebook_pixel_id,
      :social_media_image,
      :favicon_icon,
      :general_colors,
      :button_colors,
      :footer_colors,
      :header_colors,
      :base_font_size,
      :heading_font_settings,
      :button_font_settings,
      :main_menu_font_settings,
      :section_heading_font_settings,
      :social_media_accounts,
      :currency_settings,
      :body_text_font_settings,
    )
  end
end