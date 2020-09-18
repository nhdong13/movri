class Admin::PromoCodesController < Admin::AdminBaseController
  before_action :find_promo_code, only: [:edit, :update, :destroy]
  def index
    codes = PromoCode.all
  end

  def new
    @promo_code = PromoCode.new
  end

  def edit
  end

  def update
    byebug
    if @promo_code.update(promo_code_params)
      redirect_to admin_promo_codes_path
    else
      flash[:error] = 'Something went wrong!'
      render :edit
    end
  end

  def create
    @promo_code = PromoCode.new(promo_code_params)
    @promo_code.active = true
    if @promo_code.save
      redirect_to admin_promo_codes_path
    else
      flash[:error] = 'Something went wrong!'
      render :new
    end

  end
  def generate_code
    ramdom_code = (0...8).map { (65 + rand(26)).chr }.join
    if PromoCode.find_by(code: ramdom_code)
      return generate_code
    end
    respond_to do |format|
      format.html
      format.json { render json: {code: ramdom_code} }
    end
  end

  private
  def find_promo_code
    @promo_code = PromoCode.find_by(id: params[:id])
  end

  def convert_date_time
    if params[:promo_code][:start_datetime]
      start_date = params[:promo_code][:start_datetime].split(" ")[0]
      start_time = params[:promo_code][:start_time]
      params[:promo_code][:start_datetime] = "#{start_date} #{start_time} UTC"
    end
    if params[:promo_code][:end_datetime]
      end_date = params[:promo_code][:end_datetime].split(" ")[0]
      end_time = params[:promo_code][:end_time]
      params[:promo_code][:end_datetime] = "#{end_date} #{end_time} UTC"
    end
  end

  def promo_code_params
    convert_date_time
    params
      .require(:promo_code)
      .permit(
        :promo_type,
        :code,
        :fixed_amount_cents_value,
        :discount_value,
        :applies_to,
        :minimum_requirements,
        :minimum_quantity_value,
        :minimum_purchase_amount_cents_value,
        :customer_eligibility,
        :is_usage_limit_number,
        :usage_limit_number,
        :is_usage_limit_one_per_person,
        :start_datetime,
        :end_datetime,
        limit_collection_ids: [],
        limit_product_ids: [],
        limit_person_ids: [],
      )
  end

end
