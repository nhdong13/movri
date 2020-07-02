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
      )
  end
end