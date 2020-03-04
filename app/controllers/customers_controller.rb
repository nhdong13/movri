class CustomersController < ActionController::Base
  def create_contact
    if validate_contact_form
      CustomerMailer.delay.send_contact(params[:contact])
      @success = true
    else
      @success = false
    end
  end

  private
  def validate_contact_form
    params.dig(:contact, :subject).present? &&
    params.dig(:contact, :email).present? &&
    params.dig(:contact, :message).present?
  end
end