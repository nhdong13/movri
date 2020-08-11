class Admin::CommunityPagesController < Admin::AdminBaseController
  before_action :set_selected_left_navi_link
  before_action :set_service

  def index; end

  def new
    @page = Page.new(community_id: @current_community.id)
  end

  def create
    begin
      ActiveRecord::Base.transaction do
        @page = @current_community.pages.create(page_params)
      end
    rescue => exception
      logger.error("Errors in adding new page.")
      flash[:error] = "Something went wrong when adding a new page."
    end
  
    redirect_to admin_community_pages_path(@current_community)
  end

  def edit
    @page = Page.find_by(id: params[:id])
  end

  def update
    @page = Page.find_by(id: params[:id])
    @page.update(page_params)

    redirect_to admin_community_pages_path(@current_community)
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

  def page_params
    params.require(:page).permit(
      :name,
      :url
    )
  end
end