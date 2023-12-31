class Admin::PersonCustomFieldsController < Admin::AdminBaseController
  before_action :set_selected_left_navi_link
  before_action :set_service

  def new
    @service.new_custom_field
  end

  def create
    success = @service.create
    if success
      redirect_to admin_person_custom_fields_path
    else
      flash[:error] = I18n.t('admin.person_custom_fields.saving_failed')
      render :new
    end
  end

  def edit
    @service.find_custom_field
  end

  def update
    @service.update
    redirect_to admin_person_custom_fields_path
  end

  def destroy
    @service.destroy
    redirect_to admin_person_custom_fields_path
  end

  def order
    @service.order
    render body: nil, status: :ok
  end

  def person_profile
    respond_to do |format|
      format.html
      format.json { render json: Person.all, each_serializer: PersonSerializer }
    end
  end

  def person_information
    person = Person.find(params[:id])
    transaction = Transaction.find_by(id: params[:transaction_id])
    transaction.starter = person
    shipping_address = person&.shipping_address
    billing_address = person&.billing_address
    transaction.update(shipping_address_id: shipping_address&.id)
    transaction.update(billing_address_id: billing_address&.id)
    @person_information = {
      person: person,
      shipping_address: shipping_address,
      billing_address: billing_address,
      transaction: transaction
    }

    respond_to do |format|
      format.html
      format.js { render layout: false }
      format.json {
        @person_information
      }
    end
  end

  private

  def set_selected_left_navi_link
    @selected_left_navi_link = "user_fields"
  end

  def set_service
    @service = Admin::PersonCustomFieldsService.new(
      community: @current_community,
      params: params)
  end
end
