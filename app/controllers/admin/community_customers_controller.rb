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

  def update
    begin
      ActiveRecord::Base.transaction do
        @service.update
      end
    rescue => exception
      logger.error("Errors in updating customer.")
      flash[:error] = t("layouts.notifications.add_new_customer_failed")
    end

    redirect_to admin_community_customer_path(@current_community, params[:person][:id])
  end

  def show
    @customer = Person.find_by(id: params[:uuid])
    render_not_found! unless @customer
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