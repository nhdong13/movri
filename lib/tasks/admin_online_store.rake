namespace :admin_online_store do
  task create_seed_data: :environment do
    com = Community.first
    online_store = OnlineStore.find_or_create_by(community_id: com.id)
    sections = %w(Header Slideshow HighlightBanner)
    sections.each do |s|
      model = s.constantize
      record = model.new(online_store_id: online_store.id)
      record.save(validate: false)
      online_store.sections.create(
        name: s,
        sectionable_id: record.id,
        sectionable_type: s
      )
    end
  end
end