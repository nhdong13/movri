class Admin::CommunityDraftOrdersController < Admin::AdminBaseController
  before_action :set_selected_left_navi_link
  before_action :set_service, only: :index
  before_action :set_order, only: :edit

  def index; end

  def edit
    @rate_type = PriceCalculationService.get_rate_type_of_canada_provinces(@order.shipping_address.state_or_province)
  end

  private

  def set_selected_left_navi_link
    @selected_left_navi_link = "draft_orders"
  end

  def set_service
    @service = Admin::DraftOrdersService.new(
      community: @current_community,
      params: params)
  end

  def set_order
    @order = Transaction.find(params[:id])
  end
end
