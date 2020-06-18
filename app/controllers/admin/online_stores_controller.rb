class Admin::OnlineStoresController < Admin::AdminBaseController
  before_action :set_selected_left_navi_link
  def index
  end

  private
  def set_selected_left_navi_link
    @selected_left_navi_link = "online_store"
  end
end