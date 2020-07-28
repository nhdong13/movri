class Admin::CommunityPagesController < Admin::AdminBaseController
  before_action :set_selected_left_navi_link

  def index
    api = Prismic.api(APP_CONFIG.prismic_api_url)
    response = api.query(Prismic::Predicates.at("document.type", "page"))
    @pages = response.results
  end

  private
  
  def set_selected_left_navi_link
    @selected_left_navi_link = "pages"
  end

  def set_service
    @service = Admin::PagesService.new(
      community: @current_community,
      params: params)
  end
end