class Admin::CommunityTaxesController < Admin::AdminBaseController
  before_action :set_selected_left_navi_link
  before_action :set_service

  def index; end

  def add_tax_rates
    params[:taxes].each do |key, value|
      next if value[:tax_rate].to_f == 0.0
      tax = Tax.find_by(id: key)
      tax.tax_rates = tax.tax_rates.merge({value[:type_of_tax].to_sym => value[:tax_rate].to_f})
      tax.save
    end
    redirect_to admin_community_taxes_path
  end

  def refresh_tax_rates
    tax = Tax.find_by(id: params[:id])
    tax.update(tax_rates: {})

    redirect_to admin_community_taxes_path
  end

  private

  def set_selected_left_navi_link
    @selected_left_navi_link = "taxes"
  end

  def set_service
    @service = Admin::TaxesService.new(
      community: @current_community,
      params: params)
  end

end
