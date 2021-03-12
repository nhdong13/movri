class Admin::PeopleController < Admin::AdminBaseController
  before_action :get_person, only: :create
  def create
    if @person.present?
      return render json: {
        success: false,
        message: "The email is already used!"
      }
    else
      begin
        ActiveRecord::Base.transaction do
          person = Person.new person_params
          if person.save
            return render json: {
              success: true,
              message: ""
            }
          else
            return render json: {
              success: false,
              message: person.errors.full_messages[0]
            }
          end
        end
      rescue => e
      end
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