class PagesController < ApplicationController
  skip_before_action :verify_authenticity_token

  def show
    page = @current_community.pages.find_by(url: "/#{params[:page_url]}")
    if page
      builder_url = "https://builder.io/api/v1/html/page?apiKey=#{APP_CONFIG.buidler_io_api_key}&url=#{page.url}"
      builder_response = HTTParty.get(builder_url, follow_redirects: true)

      if builder_response.code != 404
        data = JSON.parse(builder_response.body).fetch("data")
        @content = data.fetch("html").html_safe
      else
        redirect_to error_not_found_path
      end
    else
      redirect_to error_not_found_path
    end
  end

end
