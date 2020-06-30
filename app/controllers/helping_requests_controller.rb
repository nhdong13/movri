class HelpingRequestsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :find_transaction

  def create
    @helping_request = @transaction.helping_requests.create(helping_request_params)
    @helping_request.update(person_id: @current_user.id) if @helping_request && @current_user
    success = if @helping_request.present?
      TransactionMailer.send_helping_request_to_admin(@transaction, @helping_request).deliver_now
      @success = true
    end
    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  private

  def find_transaction
    @transaction = Transaction.find_by(id: params[:transaction_id])
  end

  def helping_request_params
    params
      .require(:helping_request)
      .permit(
        :subject,
        :name,
        :email,
        :message
      )
  end
end
