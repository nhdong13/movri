class Admin::StoreHeadersController < Admin::AdminBaseController
  def update
    header = Header.find(params[:id])
    if header && header.update_attributes(header_params)
      render json: {success: true, header: header.as_json}
    else
      render json: {success: false, message: 'Something went wrong'}
    end
  end

  def upload_logo
    header = Header.find(params[:id])
    header.update_attributes(logo: params[:logo])
    render json: { success: true, logo_url: header.logo.url }
  end

  private
  def header_params
    tag_line_setting = JSON.parse(params[:store_header][:tag_line_setting])
    phone_number_setting = JSON.parse(params[:store_header][:phone_number_setting])
    contact_us_setting = JSON.parse(params[:store_header][:contact_us_setting])
    faq_setting = JSON.parse(params[:store_header][:faq_setting])
    announcement_bar_setting = JSON.parse(params[:store_header][:announcement_bar_setting])
  
    params
      .require(:store_header)
      .permit(
        :sticky_enabled,
        :announcement_enabled,
        :home_only_enabled, 
        :title,
        :link,
        :text_color,
        :background_color
      ).merge({
        tag_line_setting: tag_line_setting,
        phone_number_setting: phone_number_setting,
        contact_us_setting: contact_us_setting,
        faq_setting: faq_setting,
        announcement_bar_setting: announcement_bar_setting
      })
  end
end