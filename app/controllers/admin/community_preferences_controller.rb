class Admin::CommunityPreferencesController < Admin::AdminBaseController
  before_action :set_selected_left_navi_link
  before_action :set_service

  def edit
    binding.pry
    @preferences = @current_community.community_customizations.where(locale: locale).first
  end

  private

  def set_selected_left_navi_link
    @selected_left_navi_link = "customers"
  end

  def set_service
    @service = Admin::CustomersService.new(
      community: @current_community,
      params: params)
  end
end