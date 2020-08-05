class Admin::PeopleController < Admin::AdminBaseController
  before_action :get_person, only: :create
  def create
    if @person.present?
      render_error 'Person already existed'
    else
      person = Person.create person_params
    end
  end
  private

  def get_person
    @person ||= Person.find_by_email params[:person][:email]
  end

  def person_params
    params.require(:person).permit(:community_id, :given_name, :family_name, :email, transaction_addresses_attributes: [:id, :company, :phone, :street1, :street2, :city, :country, :state_or_province, :postal_code])
  end
end