class Admin::CommunityRedirectUrlsController < Admin::AdminBaseController
  before_action :set_selected_left_navi_link
  before_action :set_service

  def index; end

  def new
    @redirect_url = RedirectUrl.new
  end

  def create
    if @current_community.redirect_urls.create(redirect_url_params)
      redirect_to admin_community_redirect_urls_path(@current_community)
    else
      flash[:error] = t("layouts.notifications.create_url_redirect_failed")
    end
  end

  private

  def set_selected_left_navi_link
    @selected_left_navi_link = "redirect_urls"
  end

  def set_service
    @service = Admin::RedirectUrlsService.new(
      community: @current_community,
      params: params)
  end

  def redirect_url_params
    params.require(:redirect_url).permit( :from, :to )
  end
end