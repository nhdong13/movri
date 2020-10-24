class Admin::CommunityDraftOrdersController < Admin::AdminBaseController
  before_action :set_selected_left_navi_link
  before_action :set_service, only: :index
  before_action :set_order, only: [:edit, :update]

  def index; end

  def new
    @transaction = Transaction.new
  end

  def edit
    rate_type = PriceCalculationService.get_rate_type_of_canada_provinces(@order.shipping_address&.state_or_province)

    @payment_info = {
      GST: rate_type[:GST],
      PST: rate_type.key?(:pst) ? rate_type[:PST] : 0,
      total: rate_type.key?(:pst) ? @order.total_price_cents + (@order.total_price_cents * rate_type[:GST] / 100) + (@order.total_price_cents * rate_type[:PST] / 100) : @order.total_price_cents + (@order.total_price_cents * rate_type[:GST] / 100)
    }
  end

  def update
    if @order.update_attributes(transaction_params)
      redirect_to action: 'edit', id: @order.id
    end
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

  def transaction_params
    params.require(:transaction).permit(:current_state, :canceled_order_note)
  end
end
