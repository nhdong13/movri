module ManuallyBlockedDatesService
  module_function

  def get_global_blocked_dates(community)
    return Set.new unless community.global_blocked_dates.present?

    blocked_dates = []

    community.global_blocked_dates.split(",").each do |date_str|
      blocked_dates.push(date_str.to_datetime)
    end

    blocked_dates.to_set
  end

  def get_manually_blocked_dates(listing, step = 1.day)
    str_manually_blocked_dates = listing.manually_blocked_dates
    blocked_dates_ranges = str_manually_blocked_dates.split("&")

    manually_blocked_dates = Set.new

    blocked_dates_ranges.each do |str_range|
      manually_blocked_dates.merge(datetime_sequence(str_range, step))
    end

    return manually_blocked_dates
  end

  def get_padding_time_blocked_dates(listing)
    padding_time = listing.padding_time
    return [] unless padding_time && padding_time.start_date
    (padding_time.start_date.to_datetime..padding_time.end_date.to_datetime).to_a
  end


  def get_blocked_dates_with_all_transactions community, listing
    transactions = Transaction.joins(:transaction_items).where(transaction_items: {listing_id: listing.id}).complete
    transactions = transactions.select {|t| t.booking && t.booking.end_on >= Date.today}
    blocking_dates = []
    transactions.each do |transaction|
      booking = transaction.booking
      if booking
        padding_time_start = booking.start_on - community.padding_time_before.to_i
        padding_time_end = booking.end_on + community.padding_time_after.to_i
        duration_dates = (padding_time_start.to_datetime..padding_time_end.to_datetime).to_a
        blocking_dates.concat(duration_dates)
      end
    end
    blocking_dates
  end

  def get_blocked_dates_with_all_combo_listing_transactions community, listing
    # get listing_combo
    listing_combos = ListingCombo.where(listing_combo_id: listing.id)
    blocking_dates = []
    listing_combos.each do |listing_combo|
      listing_parent = Listing.admin_index.find_by(id: listing_combo.listing_id)
      transactions = Transaction.joins(:transaction_items).where(transaction_items: {listing_id: listing_parent.id}).complete
      transactions = transactions.select {|t| t.booking && t.booking.end_on >= Date.today}
      transactions.each do |transaction|
        booking = transaction.booking
        if booking
          padding_time_start = booking.start_on - community.padding_time_before.to_i
          padding_time_end = booking.end_on + community.padding_time_after.to_i
          duration_dates = (padding_time_start.to_datetime..padding_time_end.to_datetime).to_a
          blocking_dates.concat(duration_dates)
        end
      end
    end
    blocking_dates
  end

  def get_all_blocked_dates community, listing, step = 1.day
    blocked_dates = []
    blocked_dates.concat(get_global_blocked_dates(community).to_a)
    blocked_dates.concat(get_manually_blocked_dates(listing, step).to_a)
    # blocked_dates.concat(get_padding_time_blocked_dates(listing))
    if listing.available_quantity < 1
      blocked_dates.concat(get_blocked_dates_with_all_transactions(community, listing))
      blocked_dates.concat(get_blocked_dates_with_all_combo_listing_transactions(community, listing))
    end

    if listing.combo?
      listing.listing_combos.each do |listing_combo|
        listing_item = listing_combo.combo
        if listing_item.available_quantity < 1
          blocked_dates.concat(get_blocked_dates_with_all_transactions(community, listing_item))
        end
      end
    end
    blocked_dates
  end

  def datetime_sequence(str_dates, step)
    arr_dates = str_dates.split(",")
    # start_date = DateTime.parse(arr_dates.first)
    # end_date = DateTime.parse(arr_dates.last)
    start_date = DateTime.strptime(arr_dates.first, "%m/%d/%Y")
    end_date = DateTime.strptime(arr_dates.last, "%m/%d/%Y")

    dates = [start_date]
    while dates.last <= (end_date - step)
      dates << (dates.last + step)
    end

    return dates.to_set
  end
end