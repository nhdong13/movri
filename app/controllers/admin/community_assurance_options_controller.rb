class Admin::CommunityAssuranceOptionsController < Admin::AdminBaseController
  before_action :set_selected_left_navi_link
  before_action :set_service

  def index; end

  private

  def set_selected_left_navi_link
    @selected_left_navi_link = "assurance_options"
  end

  def set_service
    @service = Admin::AssuranceOptionsService.new(
      community: @current_community,
      params: params)
  end
end