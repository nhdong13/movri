class AddDefaultTaxRatesOfCanada < ActiveRecord::Migration[5.2]
  def up
    taxe_rates = [
      {province: 'alberta', province_display: 'Alberta', tax_rates: {GST: 5}},
      {province: 'british_columbia', province_display: 'British Columbia', tax_rates: {GST: 7, PST: 5}},
      {province: 'manitoba', province_display: 'Manitoba', tax_rates: {GST: 7, PST: 5}},
      {province: 'new_brunswick', province_display: 'New Brunswick', tax_rates: {HST: 15}},
      {province: 'newfoundland_and_labrador', province_display: 'Newfoundland and Labrador', tax_rates: {HST: 15}},
      {province: 'northwest_territories', province_display: 'Northwest Territories', tax_rates: {GST: 5}},
      {province: 'nova_scotia', province_display: 'Nova Scotia', tax_rates: {HST: 5}},
      {province: 'nunavut', province_display: 'Nunavut', tax_rates: {GST: 5}},
      {province: 'ontario', province_display: 'Ontario', tax_rates: {HST: 13}},
      {province: 'prince_edward_island', province_display: 'Prince Edward Island', tax_rates: {HST: 15}},
      {province: 'quebec', province_display: 'Quebec', tax_rates: {GST: 9.975, PST: 5}},
      {province: 'saskatchewan', province_display: 'Saskatchewan', tax_rates: {GST: 6, PST: 5}},
      {province: 'yukon', province_display: 'Yukon', tax_rates: {GST: 5}},
    ]

    Community.all.each do |community|
      taxe_rates.each do |tax_rate|
        Tax.find_or_create_by(community_id: community.id, province: tax_rate[:province]) do |new_tax|
          new_tax.province_display = tax_rate[:province_display]
        end
      end
    end
  end

  def down
    Community.all.each do |community|
      community.taxes.delete_all
    end
  end
end
