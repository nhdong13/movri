class AfterShipsController < ActionController::API
  def webhook
    tracking_number = params[:msg][:tracking_number]
    transaction = Transaction.find_by(tracking_number: tracking_number)
    if transaction
      SendgridMailer.new(transaction, {}, nil).send_order_delivered_mail(tracking_number)
    end
    head :ok
  end
end
