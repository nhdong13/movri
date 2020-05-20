module ManuallyBlockedDatesService
  module_function

  def get_global_blocked_dates(community)
    return unless community.global_blocked_dates.present?

    blocked_dates = []

    community.global_blocked_dates.split(",").each do |date_str|
      blocked_dates.push(date_str.to_datetime)
    end

    blocked_dates.to_set
  end

  def get_manually_blocked_dates(listing, step = 1.day)
    str_manually_blcoked_dates = listing.manually_blocked_dates
    blocked_dates_ranges = str_manually_blcoked_dates.split("&")

    manually_blocked_dates = Set.new

    blocked_dates_ranges.each do |str_range|
      manually_blocked_dates.merge(datetime_sequence(str_range, step))
    end

    return manually_blocked_dates
  end

  def datetime_sequence(str_dates, step)
    arr_dates = str_dates.split(",")
    start_date = DateTime.parse(arr_dates.first)
    end_date = DateTime.parse(arr_dates.last)

    dates = [start_date]
    while dates.last <= (end_date - step)
      dates << (dates.last + step)
    end

    return dates.to_set
  end
end
