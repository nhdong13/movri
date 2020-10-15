namespace :listings do
  task update_url: :environment do
    Listing.all.each do |listing|
      listing.update(url: listing.title.to_url)
    end
  end
end