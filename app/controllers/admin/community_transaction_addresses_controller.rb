class Admin::CommunityTransactionAddressesController < Admin::AdminBaseController
  before_action :set_transaction_address, only: :update
  
  def update
    if @transaction_address.update_attributes(transaction_address_params)
      redirect_to edit_admin_community_draft_order_path(params[:community_id], params[:transaction_id])
    end
  end

  def create
    if TransactionAddress.create(transaction_address_params)
      Person.find(transaction_address_params[:person_id]).update(default_shipping_address: TransactionAddress.last.id)
      redirect_to admin_community_customer_path(params[:community_id], transaction_address_params[:person_id])
    end
  end

  private

  def set_transaction_address
    @transaction_address = TransactionAddress.find(params[:id])
  end

  def transaction_address_params
    params.require(:transaction_address).permit(:person_id, :transaction_id, :first_name, :last_name, :company, :street1, :city, :phone, :apartment, :country, :postal_code)
  end
end
