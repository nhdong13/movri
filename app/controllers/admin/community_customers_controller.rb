class Admin::CommunityCustomersController < Admin::AdminBaseController
  before_action :set_selected_left_navi_link
  before_action :set_service

  def index; end

  def new
    @customer = Person.new
  end

  def create
    begin
      ActiveRecord::Base.transaction do
        @service.create
      end
    rescue => exception
      logger.error("Errors in adding new customer.")
      flash[:error] = t("layouts.notifications.add_new_customer_failed")
    end

    redirect_to admin_community_customers_path(@current_community)
  end

  def edit
    @customer = Person.find_by(id: params[:id])
  end

  def update
    begin
      ActiveRecord::Base.transaction do
        if @service.update
          @email = params[:person][:email]
        end
      end
    rescue => exception
      logger.error("Errors in updating customer.")
      flash[:error] = t("layouts.notifications.add_new_customer_failed")
    end
    respond_to do |format|
      format.html { redirect_to admin_community_customers_path }
      format.js { render layout: false }
    end
  end

  def show
    @customer = Person.find_by(id: params[:uuid])
    render_not_found! unless @customer
  end

  def send_confirmation_email_to_customer
    @person = Person.find_by(id: params[:id])
    email = @person.emails.last
    SendgridMailer.new().send_confirmation_mail(email, @current_community)
    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def destroy
    person = Person.find_by(id: params[:id])
    person.destroy
    redirect_to admin_community_customers_path
  end

  private

  def set_selected_left_navi_link
    @selected_left_navi_link = "customers"
  end

  def set_service
    @service = Admin::CustomersService.new(
      community: @current_community,
      params: params)
  end
end