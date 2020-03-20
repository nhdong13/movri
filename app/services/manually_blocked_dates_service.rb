module ManuallyBlockedDatesService
  module_function

  def datetime_sequence(str_dates, step)
    arr_dates = str_dates.split(",")
    start_date = DateTime.parse(arr_dates.first)
    end_date = DateTime.parse(arr_dates.last)

    dates = [start_date]
    while dates.last <= (end_date - step)
      dates << (dates.last + step)
    end

    return dates.join(",")
  end
end
