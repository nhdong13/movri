class Admin::CommunityTransactionAddressesController < Admin::AdminBaseController
  before_action :set_transaction_address, only: :update
  
  def update
    if @transaction_address.update_attributes(transaction_address_params)
      redirect_to edit_admin_community_draft_order_path(params[:community_id], params[:transaction_id])
    end
  end

  private

  def set_transaction_address
    @transaction_address = TransactionAddress.find(params[:id])
  end

  def transaction_address_params
    params.require(:transaction_address).permit(:transaction_id, :first_name, :last_name, :company, :street1, :city, :phone, :apartment, :country, :postal_code)
  end
end