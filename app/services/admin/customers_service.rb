class Admin::CustomersService
  attr_reader :community, :params

  def initialize(community:, params:)
    @params = params
    @community = community
  end

  def customers
    @customers ||= filtered_scope.paginate(page: params[:page], per_page: 30)
  end

  def create
    customer = Person.create(customer_params[:person]) do |ps|
      ps.community_id = community.id
    end
    # default_address = customer.transaction_addresses.create(customer_params[:transaction_address])
    # customer.update(default_shipping_address: default_address.id)
  end

  def update
    person = resource_scope.find_by(id: params[:id])
    person.update(customer_params[:person])
    if person.active_email
      person.active_email.update(address: customer_params[:person][:email]) if customer_params[:person][:email].present?
    else
      person.update(email: customer_params[:person][:email]) if customer_params[:person][:email].present?
    end
    # if person.shipping_address
    #   person.shipping_address.update(customer_params[:transaction_address])
    # else
    #   default_address = person.transaction_addresses.create(customer_params[:transaction_address])
    #   person.update(default_shipping_address: default_address.id)
    # end
  end

  private

  def filtered_scope
    scope = resource_scope
    if params[:q].present?
      scope = scope.search_name_or_email(community.id, "%#{params[:q]}%")
    end
    scope
  end

  def customer_params
    params.permit(
      person: [:id, :family_name, :given_name, :email, :phone_number, :agree_to_subscription, :note],
      transaction_address: [:id, :first_name, :last_name, :company, :street1, :apartment, :city, :country, :postal_code, :phone]
    )
  end

  def resource_scope
    Person.where(community_id: community.id, is_admin: false)
  end

end
