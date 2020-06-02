class PromoCodesController < ApplicationController
  def check_code
    @promo_code =  PromoCode.find_by(code: params[:code])
    respond_to do |format|
      format.html
      format.js { render layout: false }
    end

  end
end
