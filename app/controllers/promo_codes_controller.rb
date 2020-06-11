class PromoCodesController < ApplicationController
  def check_code
    @promo_code =  PromoCode.find_by(code: params[:code])

    if @promo_code
      session[:promo_code] = {code: @promo_code.code}
    else
      session[:promo_code] = {}
    end

    respond_to do |format|
      format.html
      format.js { render layout: false }
    end

  end
end
