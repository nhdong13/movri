require 'csv'

class Admin::CommunityTransactionsController < Admin::AdminBaseController
  before_action :find_transaction, only: [:edit, :update, :charge_extra_fee]
  def new; end

  def create; end

  def index
    @selected_left_navi_link = "transactions"
    @transactions_presenter = AdminTransactionsPresenter.new(@current_community, params, request.format)

    respond_to do |format|
      format.html
      format.csv do
        marketplace_name = if @current_community.use_domain
          @current_community.domain
        else
          @current_community.ident
        end

        self.response.headers["Content-Type"] ||= 'text/csv'
        self.response.headers["Content-Disposition"] = "attachment; filename=#{marketplace_name}-transactions-#{Date.today}.csv"
        self.response.headers["Content-Transfer-Encoding"] = "binary"
        self.response.headers["Last-Modified"] = Time.now.ctime.to_s

        self.response_body = Enumerator.new do |yielder|
          ExportTransactionsJob.generate_csv_for(yielder, @transactions_presenter.transactions)
        end
      end
    end
  end

  def export
    @export_result = ExportTaskResult.create
    Delayed::Job.enqueue(ExportTransactionsJob.new(@current_user.id, @current_community.id, @export_result.id))
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def export_status
    export_result = ExportTaskResult.where(:token => params[:token]).first
    if export_result
      file_url = export_result.file.present? ? export_result.file.expiring_url(ExportTaskResult::AWS_S3_URL_EXPIRES_SECONDS) : nil
      render json: {token: export_result.token, status: export_result.status, url: file_url}
    else
      render json: {status: 'error'}
    end
  end

  def edit
    if @order.shipping_address
      @tax = Tax.find_by(province: @order.shipping_address.state_or_province)
    else
      @tax = Tax.first
    end
    calculate_money_service(@order)
  end

  def update
    calculate_money_service(@order)
    @order.update!(transaction_params)
  end

  def charge_extra_fee
    result = stripe_api.charge_extra_fee(stripe_payment_params)
    if result[:success]
      redirect_to edit_admin_community_transaction_path(@current_community, @order)
    else
      flash[:error] = result[:error]
      redirect_to edit_admin_community_transaction_path(@current_community, @order)
    end
  end

  private
  def transaction_params
    params
    .require(:transaction)
    .permit(
      :tracking_number,
      :shipping_carrier
    )
  end

  def stripe_payment_params
    params
    .require(:stripe_payment)
    .permit(
      :fee_cents,
      :note
    )
  end

  def find_transaction
    @order = Transaction.find(params[:id])
  end

  def calculate_money_service(order=nil)
    transaction = order || @order
    @calculate_money = TransactionMoneyCalculation.new(transaction, session, @current_user)
  end

  def stripe_api
    StripeService::API::Api.payments_v2.new(@order, session, @current_user)
  end
end
