module DatetimeService
  module_function
  def convert_date date_string
    Date.strptime(date_string, "%m/%d/%Y")
  end

  def convert_date_to_string date_string
    date_string.strftime("%m/%d/%Y")
  end
end
