class CustomerMailer < ActionMailer::Base
  def send_contact params
    @subject = params[:subject]
    @message = params[:message]
    @c_email = params[:email]
    @c_name  = params[:name]
    mail(
      from: "#{@c_name} <#{@c_email}>",
      subject: @subject,
      to: APP_CONFIG.sales_email
    )
  end
end