class Admin::CommunityTransactionAddressesController < Admin::AdminBaseController
  before_action :set_transaction_address, only: :update

  def edit
    @address = TransactionAddress.find(params[:id])
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def update
    if @transaction_address.update_attributes(transaction_address_params)
      @address_type = @transaction_address.address_type

      respond_to do |format|
        format.html {redirect_to admin_community_customer_path(@current_community, transaction_address_params[:person_id])}
        format.js { render layout: false}
      end
    end
  end

  def create
    address = TransactionAddress.new(transaction_address_params)
    if address.save
      @address_type = transaction_address_params[:address_type] == 'shipping_address' ? 'default_shipping_address': 'default_billing_address'
      Person.find(transaction_address_params[:person_id]).update("#{@address_type}": TransactionAddress.last.id)
      @transaction_address = TransactionAddress.last
      if params[:transaction_id]
        transaction = Transaction.find_by(id: params[:transaction_id])
        if address.shipping_address?
          transaction.update(shipping_address_id: address&.id )
        else
          transaction.update(billing_address_id: address&.id )
        end
      end
      respond_to do |format|
        format.html { redirect_to admin_community_customer_path(params[:community_id], transaction_address_params[:person_id]) }
        format.js { render layout: false }
      end
    end
  end

  private

  def set_transaction_address
    @transaction_address = TransactionAddress.find(params[:id])
  end

  def transaction_address_params
    params.require(:transaction_address).permit(:address_type, :person_id, :transaction_id, :first_name, :last_name, :company, :street1, :city, :phone, :apartment, :country, :postal_code, :state_or_province)
  end
end
