namespace :sharetribe do

  namespace :community_updates do
    desc "Sends the community updates email to everyone who should receive it now"
    task :deliver => :environment do |t, args|
      CommunityMailer.deliver_community_updates
    end
  end

  namespace :landing_pages do
    desc "Install sample landing page into initializers/landing_page.rb"
    task :install_static => :environment do
      source = File.join(Rails.root, "app", "services", "custom_landing_page", "example_data.rb")
      dest = File.join(Rails.root, "config", "initializers", "landing_page.rb")

      # patch example_data
      text = File.read(source)
      text = text.gsub(/ExampleData/, "StaticData")
      # dont copy TEMPLATE_STR
      text = text.gsub(/^\s*TEMPLATE_STR = <<JSON.*JSON/m, "")
      File.open(dest, "w") {|file| file.puts text }

      puts "Created config/initializers/landing_page.rb with static template."
      puts "This needs clp_static_enabled: true in config.yml for it to take effect."
    end
  end

  desc "Cleans the auth_tokens table in the DB by deleting expired ones"
  task :delete_expired_auth_tokens => :environment do
    AuthToken.delete_expired
  end

  desc "Retries set express checkouts"
  task :retry_and_clean_paypal_tokens => :environment do
    Delayed::Job.enqueue(PaypalService::Jobs::RetryAndCleanTokens.new(1.hour.ago))
  end

  desc "Synchnorizes verified email address states from SES to local DB"
  task :synchronize_verified_with_ses => :environment do
    EmailService::API::Api.addresses.enqueue_batch_sync()
  end

  namespace :person_custom_fields do
    desc "Copying person's phone number to custom fields"
    task :copy_phone_number_community, [:community_ident] => :environment do |t, args|
      community_ident = args[:community_ident]
      if community_ident.blank?
        raise 'Invalid marketplace ident.'
      end

      community = Community.find_by!(ident: community_ident)
      PersonPhoneCopyist.copy_community(community)
    end

    desc "Remove person's phone number from custom fields"
    task :remove_phone_number_community, [:community_ident] => :environment do |t, args|
      community_ident = args[:community_ident]
      if community_ident.blank?
        raise 'Invalid marketplace ident.'
      end

      community = Community.find_by!(ident: community_ident)
      community.person_custom_fields.phone_number.destroy_all
    end
  end


  desc "Create booking for listing"
  task :create_booking_for_exist_listings => :environment do
    listings = Listing.all
    current_community = Community.last
    listings.each do |listing|
      shape = listing.listing_shape
      if shape.present?
        if shape.booking_per_hour?
          true
        elsif APP_CONFIG.harmony_api_in_use && shape.booking?
          community_uuid = Community.last.uuid_object
          listing_uuid = listing.uuid_object
          author_uuid = Person.find_by(username: "adminm").uuid_object
          author_id = Person.find_by(username: "adminm").id
          SessionContextStore.set({:marketplace_id => 1,:marketplace_uuid => community_uuid,:user_id => author_id,:user_uuid => author_uuid,:user_role => :admin})
          HarmonyService.new().create_bookable(community_uuid, listing_uuid, author_uuid).success
        else
          true
        end
      end
    end
  end


  desc "Update tab for listing"
  task :update_tabs_for_listing => :environment do
    tabs = %w[spec overview q_a in_the_box not_in_the_box key_feature]
    Listing.all.each do |listing|
      tabs.each do |tab|
        begin
          l_tabs = listing.listing_tabs.where(tab_type: tab).last
          unless l_tabs
            l_tabs = listing.listing_tabs.create(title: tab.split("_").join(" "), tab_type: tab, description: listing.send(tab))
          end
        rescue
        end
      end
    end
    ListingTab.where(tab_type: 'q_a').update_all(tab_type: 'q_and_a')
    ListingTab.where(tab_type: 'spec').update_all(tab_type: 'specs')
    ListingTab.where(tab_type: 'key_feature').update_all(tab_type: 'key_features')
  end
end
