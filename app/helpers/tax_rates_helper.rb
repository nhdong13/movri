module TaxRatesHelper

  def tax_rates_in_string tax_rates
    i = 0
    result = ""
    tax_rates.each do |key, value|
      i += 1
      if i == tax_rates.keys.size
        result += " #{value.to_i == value ? value.to_i : value}% #{key}"
      else
        result += " #{value.to_i == value ? value.to_i : value}% #{key} +"
      end
    end
    result
  end

  def type_of_tax_options tax_rates
    ([:HST, :GST, :PST, :QST] - tax_rates.keys).map(&:to_s)
  end

  def total tax_rates
    total = 0.0
    tax_rates.each do |key, value|
      total += value.to_f
    end
    "#{total.to_i == total ? total.to_i : total} %"
  end
end
