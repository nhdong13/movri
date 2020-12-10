class Admin::CommunityDraftOrdersController < Admin::AdminBaseController
  before_action :set_selected_left_navi_link
  before_action :set_service, only: :index
  before_action :set_order, only: [:edit, :update]

  def index
    @draft_orders =  Transaction.all.draft_order
  end

  def new
    @transaction = Transaction.new
  end

  def edit
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
