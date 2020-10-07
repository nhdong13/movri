class Admin::CustomersService
  attr_reader :community, :params

  def initialize(community:, params:)
    @params = params
    @community = community
  end

  def customers
    @customers ||= resource_scope.paginate(page: params[:page], per_page: 30)
  end

  def create
    customer = Person.create(customer_params[:person]) do |ps|
      ps.community_id = community.id
    end
    default_address = customer.transaction_addresses.create(customer_params[:transaction_address])
    customer.update(default_shipping_address: default_address.id)
  end

  def update
    resource_scope.update(customer_params[:person])
  end

  private

  def customer_params
    params.permit(
      person: [:family_name, :given_name, :email, :phone_number, :agree_to_subscription, :note],
      transaction_address: [:first_name, :last_name, :company, :street1, :apartment, :city, :country, :postal_code, :phone]
    )
  end

  def resource_scope
    Person.where(community_id: community.id, is_admin: false)
  end

end
