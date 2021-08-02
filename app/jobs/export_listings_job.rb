require 'csv'
require "axlsx"
class ExportListingsJob < Struct.new(:community_id, :export_task_id, :export_as_excel)
  attr_accessor :listing
  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def perform
    community = Community.find(community_id)
    export_task = ExportTaskResult.find(export_task_id)
    export_task.update(status: 'started')

    marketplace_name = community.use_domain ? community.domain : community.ident
    filename = "#{marketplace_name}-listings-#{Time.zone.today}-#{export_task.token}."

    if export_as_excel
      export_content = generate_excel_content(community)
      filename += "xlsx"
    else
      export_content = generate_csv_content(community)
      filename += "csv"
    end
    
    export_task.original_filename = filename
    export_task.original_extname = File.extname(filename).delete('.')
    export_task.update(status: 'finished', file: FakeFileIO.new(filename, export_content))
  end

  def generate_csv_content(community)
    I18nHelper.initialize_community_backend!(community.id, community.locales)

    locale = community.default_locale

    # local cache for category names to avoid extra SQL
    categories_list = community.categories.map do |category|
      [
        category.id,
        {parent: category.parent_id, name: category.display_name(locale)}
      ]
    end
    categories_hash = Hash[categories_list]

    generate_csv_rows(community.listings.for_export, locale, categories_hash).join("")
  end

  def generate_csv_rows(listings, locale, categories)
    out = []
    # first line is column names
    out << %w{
      listing_id
      listing_title
      user_id
      created_at
      updated_at
      status
      category
      order_type
      main_image_url
    }.to_csv(force_quotes: true)
    listings.each do |listing|
      @listing = listing
      out << [
        listing.id,
        listing.title,
        listing.author_id,
        listing.created_at && I18n.l(listing.created_at, format: '%Y-%m-%d %H:%M:%S'),
        listing.updated_at && I18n.l(listing.updated_at, format: '%Y-%m-%d %H:%M:%S'),
        status_title(locale),
        category_title(listing.category_id, categories),
        I18n.t(listing.shape_name_tr_key, locale: locale),
        main_image_url
      ].to_csv(force_quotes: true)
    end
    out
  end

  def generate_excel_content(community)
    I18nHelper.initialize_community_backend!(community.id, community.locales)
    locale = community.default_locale

    generate_excel_rows(community)
  end

  def generate_excel_rows(community)
    book = Axlsx::Package.new
    workbook = book.workbook
    sheet = workbook.add_worksheet name: "Customer List"
    listings = community.listings.for_export
    locale = community.default_locale

    sheet.add_row(%w{
      ID
      Title
      Description
      Availability
      Condition
      Price
      Link
      main_image_url
      Brand
    })

    listings.each do |listing|
      @listing = listing
      sheet.add_row [
        listing.id,
        listing.title,
        listing_overview,
        "In Stock",
        "New",
        listing_price,
        listing_url(community.domain, locale),
        main_image_url,
        listing.sku
      ]
    end

    book.to_stream.read
  end

  private
  def status_title(locale)
    status =
      if listing.approval_pending? || listing.approval_rejected?
        listing.state
      elsif listing.valid_until && listing.valid_until < DateTime.current
        'expired'
      else
        listing.open? ? 'open' : 'closed'
      end
    I18n.t("admin.communities.listings.#{status}", locale: locale)
  end

  def category_title(id, categories)
    out = []
    record = categories[id]
    while record
      out << record[:name]
      record = categories[record[:parent]]
    end
    out.reverse.join(" | ")
  end

  def main_image_url
    listing.listing_images.first&.image&.url
  end

  def listing_price
    ActionController::Base.helpers.number_to_currency(MoneyViewUtils.to_CAD(listing.price_cents))
  end

  def listing_url domain, locale
    Rails.application.routes.url_helpers.listing_url(id: listing.url, locale: locale, host: domain)
  end

  def listing_overview
    counter = 0
    pointer = 0
    description = ""
    description_present = false
    raw_description = listing&.overview_tab&.description
    while counter >= 0 && pointer < raw_description.length
      current_char = raw_description[pointer]
      return description if description_present && raw_description[pointer] == ">"
      if current_char == "<"
        counter += 1
      elsif current_char == ">"
        counter -= 1
      else
        if counter == 0
          description_present = true
          description += current_char
        end
      end
      pointer += 1
    end
    description
  end
end
