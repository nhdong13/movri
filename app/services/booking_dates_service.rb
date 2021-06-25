class BookingDatesService
  attr_reader :community, :listing

  def initialize _community, _listing
    @community = _community
    @listing = _listing
  end

  def refine_booking_dates booking_session
    start_date = booking_session[:start_date]
    end_date = booking_session[:end_date]

    unless start_date.present? && end_date.present?
      return default_valid_booking_dates
    end

    start_date = convert_to_date(start_date)
    end_date = convert_to_date(end_date)
    today = convert_to_date(get_today)

    is_bad_booking_dates =
      start_date > end_date ||
      start_date < today ||
      booking_dates_conflict_blocked_dates?

    return default_valid_booking_dates if is_bad_booking_dates
  end

  private

  def booking_dates_conflict_blocked_dates?
  end

  def default_valid_booking_dates
    start_date
    end_date
    data = BookingDaysCalculation.call(start_date, end_date)
    return start_date, end_date, data[:total_days]
  end

  def convert_to_date value
    Date.strptime(value, "%m/%d/%Y")
  end

  def get_today
    @today ||= Date.today.strftime("%m/%d/%Y")
  end

  def all_blocked_dates
    @all_blocked_dates ||=
      ManuallyBlockedDatesService.get_all_blocked_dates(
        community,
        listing,
        1.day
      ).uniq.sort
  end

end