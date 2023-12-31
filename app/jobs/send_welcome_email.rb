class SendWelcomeEmail < Struct.new(:person_id, :community_id)

  include DelayedAirbrakeNotification

  def perform
    set_service_name!(community_id)
    person = Person.find(person_id)
    community = Community.find(community_id)
    unless person.has_admin_rights?(community)
      MailCarrier.deliver_now(SendgridMailer.new().send_welcome_mail(person))
    end
  end

  private

  def set_service_name!(community_id)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

end
