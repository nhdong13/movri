module BookingDaysCalculation
  module_function

  def call(params_start_date, params_end_date)
    # eg. "01/15/2020" => ["01", "15", "2020"]
    tmp_arr_start_date = params_start_date.split("/")
    tmp_arr_end_date = params_end_date.split("/")

    # eg. ["01", "15", "2020"] => ["15", "01", "2020"]
    tmp_arr_start_date[0], tmp_arr_start_date[1] = tmp_arr_start_date[1], tmp_arr_start_date[0]
    tmp_arr_end_date[0], tmp_arr_end_date[1] = tmp_arr_end_date[1], tmp_arr_end_date[0]

    # eg. ["15", "01", "2020"] => "15/01/2020"
    # this is the format that can convert to datetime object
    start_date = tmp_arr_start_date.join("/").to_datetime
    end_date = tmp_arr_end_date.join("/").to_datetime

    {
      start_date: params_start_date,
      end_date: params_end_date,
      total_days: (end_date - start_date).to_i
    }
  end
end
