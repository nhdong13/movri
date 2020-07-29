class MigrateRedirectUrlForExistingListing < ActiveRecord::Migration[5.2]
  def up
    Listing.all.each do |listing|
      RedirectUrl.create(
        redirectable: listing,
        community_id: listing.community_id,
        from: listing.to_param,
        to: listing.to_param
      )
    end
  end

  def down
    RedirectUrl.where(redirectable_type: 'Listing').delete_all;
  end
end
