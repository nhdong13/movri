class Admin::OnlineStoreController < Admin::AdminBaseController
  before_action :set_selected_left_navi_link
  def show
    @online_store = @current_community.online_store
    @sections = @online_store.sections || []
    # @slideshow = 
  end

  private
  def set_selected_left_navi_link
    @selected_left_navi_link = "online_store"
  end
end