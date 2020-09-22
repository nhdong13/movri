class PromoCodesController < ApplicationController
  def check_code
    @promo_code =  PromoCode.find_by(code: params[:code])
    if @promo_code
      promo_code_service(@promo_code)
      @result = @promo_code_service.check_if_promo_code_can_use
      session[:promo_code] = {code: @promo_code.code}
    else
      @result = {success: false, message: 'This code is invalid or already used.'}
      session[:promo_code] = {}
    end
    respond_to do |format|
      format.html
      format.js { render layout: false }
    end

  end

  private
  def promo_code_service(promo_code)
    @promo_code_service ||= PromoCodeService.new(promo_code, session, @current_user)
  end
end
