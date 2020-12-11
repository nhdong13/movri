class Admin::CommunityDraftOrdersController < Admin::AdminBaseController
  before_action :set_selected_left_navi_link
  before_action :set_service, only: :index
  before_action :set_order, only: [:edit, :update]

  def index
    @draft_orders = Transaction.all.draft_order.abandoned_order.order(id: :desc)
    @draft_orders = @draft_orders.paginate(page: params[:page])
  end

  def new
    @transaction = Transaction.new
  end

  def edit
    person = @transaction.starter
    shipping_address =  @transaction.shipping_address
    billing_address = @transaction.billing_address
    @person_information = {
      person: person,
      shipping_address: shipping_address,
      billing_address: billing_address,
      transaction: @transaction
    }
  end

  def update
    if @transaction.update_attributes(transaction_params)
      redirect_to action: 'edit', id: @transaction.id
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
    @transaction = Transaction.find(params[:id])
  end

  def transaction_params
    params.require(:transaction).permit(:current_state, :canceled_order_note)
  end
end
