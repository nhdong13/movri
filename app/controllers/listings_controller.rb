class ListingsController < ApplicationController
  class ListingDeleted < StandardError; end

  # Skip auth token check as current jQuery doesn't provide it automatically
  skip_before_action :verify_authenticity_token, :only => [:close, :update, :follow, :unfollow]

  before_action :only => [:edit, :edit_form_content, :update, :close, :follow, :unfollow] do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_this_content")
  end

  before_action :only => [:new, :new_form_content, :create] do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_create_new_listing", :sign_up_link => view_context.link_to(t("layouts.notifications.create_one_here"), sign_up_path)).html_safe
  end

  before_action :save_current_path, :only => :show
  before_action :ensure_authorized_to_view, :only => [:show, :follow, :unfollow]

  before_action :only => [:close] do |controller|
    controller.ensure_current_user_is_listing_author t("layouts.notifications.only_listing_author_can_close_a_listing")
  end

  before_action :only => [:edit, :edit_form_content, :update, :delete, :remove_user_manual, :add_tab] do |controller|
    controller.ensure_current_user_is_listing_author t("layouts.notifications.only_listing_author_can_edit_a_listing")
  end

  before_action :ensure_is_admin, :only => [:move_to_top, :show_in_updates_email]

  before_action :is_authorized_to_post, :only => [:new, :create]
  before_action :set_sessions

  def index
    @selected_tribe_navi_tab = "home"

    respond_to do |format|
      # Keep format.html at top, as order is important for HTTP_ACCEPT headers with '*/*'
      format.html do
        # Username is passed in person_id parameter for historical reasons.
        # In the future the actual parameter name should be changed to better
        # express its purpose. However this is a large change as there are quite a few
        # resources nested under the people resource.
        username = params[:person_id]

        if request.xhr? && username # AJAX request to load on person's listings for profile view
          listings_presenter = ListingsPersonPresenter.new(@current_community, @current_user, username, params)
          render :partial => "listings/profile_listings", locals: {
            person: listings_presenter.person, limit: listings_presenter.per_page, listings: listings_presenter.listings }
        else
          redirect_to search_path
        end
      end

      format.atom do
        @feed_presenter = ListingsFeedPresenter.new(@current_community, @current_community.shapes, @current_community.transaction_processes, params)
        render layout: false
      end
    end
  end

  def listing_bubble
    if params[:id]
      @listing = Listing.find(params[:id])
      if Policy::ListingPolicy.new(@listing, @current_community, @current_user).visible?
        render :partial => "homepage/listing_bubble", :locals => { :listing => @listing }
      else
        render :partial => "bubble_listing_not_visible"
      end
    end
  end

  # Used to show multiple listings in one bubble
  def listing_bubble_multiple
    ids = params[:ids].split(",").map(&:to_i)

    @listings = if @current_user || !@current_community.private?
      @current_community.listings.where(listings: {id: ids}).order("listings.created_at DESC")
    else
      []
    end

    if !@listings.empty?
      render :partial => "homepage/listing_bubble_multiple"
    else
      render :partial => "bubble_listing_not_visible"
    end
  end

  def show
    redirectUrl = RedirectUrl.where(from: params[:id]).first
    if Listing.find(params[:id]).deleted? || redirectUrl.present?
      redirect_to listing_path(id: redirectUrl.to)
    else
      @selected_tribe_navi_tab = "home"
      make_onboarding_popup

      make_listing_presenter
      @listing_presenter.form_path = new_transaction_path(listing_id: @listing.id)
      @seo_service.listing = @listing
      @support_info = SupportInfo.last

      # Remove session booking dates if it in blocked dates
      if @listing.manually_blocked_dates && session[:booking]
        manually_blocked_dates_arr = @listing.manually_blocked_dates.split("&")

        # convert session[:booking][:start_date]: mm/dd/yyy => dd/mm/yyy
        arr_start_date = session[:booking][:start_date].split("/")
        arr_start_date[0], arr_start_date[1] = arr_start_date[1], arr_start_date[0]
        start_date = arr_start_date.join("/")

        # convert session[:booking][:end_date]: mm/dd/yyy => dd/mm/yyy
        arr_end_date = session[:booking][:end_date].split("/")
        arr_end_date[0], arr_end_date[1] = arr_end_date[1], arr_end_date[0]
        end_date = arr_end_date.join("/")

        # Reset session[:booking] if user choose the end date before start date
        if start_date.to_datetime > end_date.to_datetime
          session[:booking] = nil
        end

        manually_blocked_dates_arr.each do |range_date|
          if range_date.split(",").first.present? && range_date.split(",").last.present?
            if start_date.to_datetime.between?(range_date.split(",").first.to_datetime, range_date.split(",").last.to_datetime)
              session[:booking] = nil
              break
            end

            if end_date.to_datetime.between?(range_date.split(",").first.to_datetime, range_date.split(",").last.to_datetime)
              session[:booking] = nil
              break
            end
          else
            session[:booking] = nil
          end
        end
      end

      session[:recently_viewed] ||= []
      session[:recently_viewed] = session[:recently_viewed].unshift(@listing.id).uniq

      record_event(
        flash.now,
        "ListingViewed",
        { listing_id: @listing.id,
          listing_uuid: @listing.uuid_object.to_s,
          payment_process: @listing_presenter.process })
    end
  end

  def new
    @listing = Listing.new
    make_listing_presenter
  end

  def new_form_content
    return redirect_to action: :new unless request.xhr?

    @listing = Listing.new

    form_content
  end

  def edit_form_content
    return redirect_to action: :edit unless request.xhr?

    @listing.ensure_origin_loc

    form_content
  end

  def create
    if new_listing_author != @current_user
      logger.info "ADMIN ACTION: admin='#{@current_user.id}' create listing params=#{params.inspect}"
    end
    params[:listing].delete("origin_loc_attributes") if params[:listing][:origin_loc_attributes][:address].blank?

    shape = get_shape(Maybe(params)[:listing][:listing_shape_id].to_i.or_else(nil))
    listing_uuid = UUIDUtils.create

    # TODO: comment this until find the way to re-connect Harmany
    unless create_booking(shape, listing_uuid)
      flash[:error] = t("listings.error.create_failed_to_connect_to_booking_service")
      return redirect_to new_listing_path
    end

    tabs = params.to_unsafe_hash[:listing][:tabs]
    result = ListingFormViewUtils.build_listing_params(shape, listing_uuid, params, @current_community)
    unless result.success
      flash[:error] = t("listings.error.something_went_wrong", error_code: result.data.join(', '))
      redirect_to new_listing_path
      return
    end
    @listing = Listing.new(result.data)
    service = Admin::ListingsService.new(community: @current_community, params: params, person: @current_user)
    ActiveRecord::Base.transaction do
      @listing.author = new_listing_author
      service.create_state(@listing)
      if @listing.save
        create_or_update_tabs(@listing, tabs)
        # create_or_update_accessories(result.data[:recommended_accessory_ids])
        subcategory_ids = params[:subcategory_ids] ? params[:subcategory_ids].uniq.reject(&:empty?) : []
        childcategory_ids = params[:childcategory_ids] ? params[:childcategory_ids].uniq.reject(&:empty?) : []
        create_or_update_category_listings([result.data[:category_ids]], subcategory_ids, childcategory_ids)
        create_or_update_listing_assessory(@listing, params.to_unsafe_hash[:listing_accessory])
        @listing.upsert_field_values!(params.to_unsafe_hash[:custom_fields])
        @listing.reorder_listing_images(params, @current_user.id)
        notify_about_new_listing
        service.create_successful(@listing)

        if shape.booking?
          anchor = shape.booking_per_hour? ? 'manage-working-hours' : 'manage-availability'
          @listing.working_hours_new_set(force_create: true) if shape.booking_per_hour?
          redirect_to listing_path(@listing, anchor: anchor, listing_just_created: true), status: :see_other
        else
          redirect_to @listing, status: :see_other
        end
      else
        logger.error("Errors in creating listing: #{@listing.errors.full_messages.inspect}")
        flash[:error] = t(
          "layouts.notifications.listing_could_not_be_saved",
          :contact_admin_link => view_context.link_to(t("layouts.notifications.contact_admin_link_text"), new_user_feedback_path, :class => "flash-error-link")
        ).html_safe
        redirect_to new_listing_path
      end
    end
  end

  def edit
    @selected_tribe_navi_tab = "home"

    make_listing_presenter
    @listing.ensure_origin_loc

    @custom_field_questions = @listing.category.custom_fields.where(community_id: @current_community.id)
    @numeric_field_ids = numeric_field_ids(@custom_field_questions)

    shape = select_shape(@current_community.shapes, @listing)
    if shape[:id]
      @listing.listing_shape_id = shape[:id]
    end
    render locals: { form_content: form_locals(shape) }
  end

  def update
    if (params[:listing][:origin] && (params[:listing][:origin_loc_attributes][:address].empty? || params[:listing][:origin].blank?))
      params[:listing].delete("origin_loc_attributes")
      if @listing.origin_loc
        @listing.origin_loc.delete
      end
    end

    shape = get_shape(params[:listing][:listing_shape_id])

    unless create_booking(shape, @listing.uuid_object)
      flash[:error] = t("listings.error.update_failed_to_connect_to_booking_service")
      return redirect_to edit_listing_path(@listing)
    end

    tabs = params.to_unsafe_hash[:listing][:tabs]
    result = ListingFormViewUtils.build_listing_params(shape, @listing.uuid_object, params, @current_community)
    unless result.success
      flash[:error] = t("listings.error.something_went_wrong", error_code: result.data.join(', '))
      return redirect_to edit_listing_path
    end
    listing_params = result.data.merge(@listing.closed? ? {open: true} : {})
    service = Admin::ListingsService.new(community: @current_community, params: params, person: @current_user)
    listing_params.merge!(service.update_by_author_params(@listing))

    old_availability = @listing.availability.to_sym
    update_successful = @listing.update_fields(listing_params)
    @listing.upsert_field_values!(params.to_unsafe_hash[:custom_fields])

    if update_successful
      create_or_update_tabs(@listing, tabs)
      # create_or_update_accessories(result.data[:recommended_accessory_ids])
      subcategory_ids = params[:subcategory_ids] ? params[:subcategory_ids].uniq.reject(&:empty?) : []
      childcategory_ids = params[:childcategory_ids] ? params[:childcategory_ids].uniq.reject(&:empty?) : []
      create_or_update_category_listings([result.data[:category_ids]], subcategory_ids, childcategory_ids)
      create_or_update_listing_assessory(@listing, params.to_unsafe_hash[:listing_accessory])
      if shape.booking_per_hour? && !@listing.per_hour_ready
        @listing.working_hours_new_set(force_create: true)
      end
      if @listing.location
        location_params = ListingFormViewUtils.permit_location_params(params)
        @listing.location.update(location_params)
      end
      flash[:notice] = update_flash(old_availability: old_availability, new_availability: shape[:availability])
      Delayed::Job.enqueue(ListingUpdatedJob.new(@listing.id, @current_community.id))
      reprocess_missing_image_styles(@listing) if @listing.closed?
      service.update_by_author_successful(@listing)
      redirect_to @listing
    else
      logger.error("Errors in editing listing: #{@listing.errors.full_messages.inspect}")
      flash[:error] = t("layouts.notifications.listing_could_not_be_saved", :contact_admin_link => view_context.link_to(t("layouts.notifications.contact_admin_link_text"), new_user_feedback_path, :class => "flash-error-link")).html_safe
      redirect_to edit_listing_path(@listing)
    end
  end

  def close
    make_listing_presenter
    @listing.update_attribute(:open, false)
    respond_to do |format|
      format.html { redirect_to @listing }
      format.js { render :layout => false }
    end
  end

  def move_to_top
    @listing = @current_community.listings.find(params[:id])

    # Listings are sorted by `sort_date`, so change it to now.
    @listing.update_attribute(:sort_date, Time.now)
    redirect_to homepage_index_path
  end

  def show_in_updates_email
    @listing = @current_community.listings.find(params[:id])
    @listing.update_attribute(:updates_email_at, Time.now)
    render :body => nil, :status => :ok
  end

  def follow
    change_follow_status("follow")
  end

  def unfollow
    change_follow_status("unfollow")
  end

  def verification_required

  end

  def delete
    if @listing.update(deleted: true)
      flash[:notice] = t("layouts.notifications.listing_deleted")
      redirect_to listings_person_settings_path(@current_user.username)
    else
      flash[:error] = @listing.errors.full_messages.join(', ')
      redirect_to @listing
    end
  end

  def ensure_current_user_is_listing_author(error_message)
    @listing = Listing.find(params[:id])
    return if current_user?(@listing.author) || @current_user.has_admin_rights?(@current_community)

    flash[:error] = error_message
    redirect_to @listing and return
  end

  def add_item_to_cart
    listing = Listing.find_by(id: params[:id])

    # Return if listing does not eixst
    unless listing
      return render json: {
        success: false,
        message: "Not found"
      }, status: 404
    end

    # Add item to session
    session[:cart] ||= {}
    listing_id = params[:id]
    session[:cart][listing_id] = session[:cart][listing_id] ? (session[:cart][listing_id].to_i + params[:quantity].to_i) : params[:quantity].to_i
    transaction_items_service.add_new_transaction_items(listing_id) if transaction_items_service

    # Get total items in cart
    cart_total_items = session[:cart].values.sum

    render json: {
      success: true,
      message: "Add item to cart sucessfully",
      data: {
        item: listing_id,
        item_count: session[:cart][listing_id],
        cart: session[:cart],
        total_items: cart_total_items
      }
    }
  end

  def remove_cart_item
    listing = Listing.find_by(id: params[:id])

    # Return if listing does not eixst or listing does not exist in cart
    unless listing && session[:cart][params[:id]]
      return render json: {
        success: false,
        message: "Not found"
      }, status: 404
    end

    listing_id = params[:id]

    session[:cart].delete(listing_id)

    cart_total_items = session[:cart].values.sum

    transaction_items_service.remove_listing_item_out_of_transaction(listing_id) if transaction_items_service

    render json: {
      success: true,
      message: "Remove item sucessfully",
      data: {
        delete_item: listing_id,
        total_items: cart_total_items
      }
    }
  end

  def plus_item
    listing = Listing.find_by(id: params[:id])

    # Return if listing does not eixst or listing does not exist in cart
    unless listing && session[:cart][params[:id]]
      return render json: {
        success: false,
        message: "Not found"
      }, status: 404
    end

    listing_id = params[:id]

    session[:cart][listing_id] += 1

    # Handle to show total price after change number of this listing
    price_cents = PriceCalculationService.calculate(listing, ListingViewUtils.get_booking_days(session)) * session[:cart][listing_id]
    number_price = Money.new(price_cents, 'USD')
    value_in_cart = MoneyViewUtils.to_humanized(number_price)

    transaction_items_service.increase_quantity_of_transaction_items(listing_id) if transaction_items_service

    render json: {
      success: true,
      message: "Plus item sucessfully",
      data: {
        item: listing_id,
        new_quantity: session[:cart][listing_id],
        total_items: session[:cart].values.sum,
        value_in_cart: value_in_cart
      }
    }
  end

  def minus_item
    listing = Listing.find_by(id: params[:id])

    # Return if listing does not eixst or listing does not exist in cart
    unless listing && session[:cart][params[:id]]
      return render json: {
        success: false,
        message: "Not found"
      }, status: 404
    end

    listing_id = params[:id]

    # True if item will be destroy
    delete = false

    if session[:cart][listing_id] == 1
      session[:cart].delete(listing_id)
      delete = true
    else
      session[:cart][listing_id] -= 1
    end

    # Handle to show total price after change number of this listing
    value_in_cart = 0

    if session[:cart][listing_id]
      price_cents = PriceCalculationService.calculate(listing, ListingViewUtils.get_booking_days(session)) * session[:cart][listing_id]
      number_price = Money.new(price_cents, 'USD')
      value_in_cart = MoneyViewUtils.to_humanized(number_price)
    end

    transaction_items_service.reduce_quantity_of_transaction_items(listing_id) if transaction_items_service

    render json: {
      success: true,
      message: "Minus item sucessfully",
      data: {
        delete: delete,
        item: listing_id,
        new_quantity: session[:cart][listing_id],
        total_items: session[:cart].values.sum,
        value_in_cart: value_in_cart
      }
    }
  end

  def change_number_of_item
    id = params[:id]
    @item_count = params[:total].to_i
    @promo_code = PromoCode.find_by(code: params[:promo_code])
    @listing = Listing.find_by_id(id)
    if session[:cart].key?(id) && @item_count > 0
      session[:cart][id] = @item_count
    end
    transaction_items_service.increase_quantity_of_transaction_items(@listing.id, @item_count) if transaction_items_service

    # Get total items in cart
    @cart_total_items = session[:cart].values.sum
    respond_to do |format|
      format.html
      format.js {render layout: false}
    end
  end

  def change_coverage_type
    session[:coverage] ||= {}
    session[:coverage][params[:id]] = params[:coverage_type]
    @promo_code = PromoCode.find_by(code: params[:promo_code])
    respond_to do |format|
      format.html
      format.js {render layout: false}
    end
  end

  def load_cart
    unless session[:cart]
      render json: {
        success: false,
        message: "Not found"
      }, status: 404
    end

    # Get total items in cart
    cart_total_items = session[:cart].values.sum

    render json: {
      success: true,
      message: "Load cart sucessfully",
      data: {
        cart: session[:cart],
        total_items: cart_total_items
      }
    }
  end

  def cart
    @have_blocked_dates = Listing.where(id: session[:cart].keys).pluck(:manually_blocked_dates).present?
    make_listing_presenter
    @blocked_dates = @listing_presenter.blocked_dates_result[1].to_a
    global_blocked_dates = ManuallyBlockedDatesService.get_global_blocked_dates(@current_community).to_a
    @blocked_dates.concat(global_blocked_dates) if global_blocked_dates.any?
    # reset session coverage
    session[:coverage] = {}
    # manually_blocked_dates = ManuallyBlockedDatesService.get_manually_blocked_dates(@listing, 1.day).to_a
    # @blocked_dates.concat(manually_blocked_dates) if @listing.manually_blocked_dates
  end

  def change_booking_days
    # missing params
    return unless params[:start_date] && params[:end_date]
    # pass same value for start and end date
    if params[:start_date] == params[:end_date]
      return render json: {
        success: false
      }
    end
    # pass same value in session
    if session[:booking] && params[:start_date] == session[:booking][:start_date] && params[:end_date] == session[:booking][:end_date]
      return render json: {
        success: false
      }
    end

    data = BookingDaysCalculation.call(params[:start_date], params[:end_date])

    # Set to session
    session[:booking] ||= {}
    session[:booking][:start_date] = data[:start_date]
    session[:booking][:end_date] = data[:end_date]
    session[:booking][:total_days] = data[:total_days]

    render json: {
      success: true,
      data: {
        total_days: session[:booking][:total_days],
        start_date: session[:booking][:start_date],
        end_date: session[:booking][:end_date]
      }
    }
  end

  def get_shipping_rates_from_postmen
    listing = Listing.find_by(id: params[:id])

    if params[:zipcode].blank? || listing.nil?
      return render json: {
        success: false,
        message: "Wrong or missing parameters"
      }, status: 400
    end

    if listing.packing_dimensions.blank?
      return render json: {
        success: false,
        message: "The listing has not dimensions to calculate"
      }, status: 404
    end

    request_body = ShippingRatesService.create_body_request_to_postmen(params)
    response = Faraday.post(
      APP_CONFIG.postmen_get_shipping_rates_url,
      request_body,
      "Content-Type" => "application/json",
      "postmen-api-key" => APP_CONFIG.postmen_api_key)

    if response.status == 200
      response_body = JSON.parse(response.body)
      shipping_rates = ShippingRatesService.convert_to_shipping_selection(response_body)

      render json: {
        success: true,
        message: "Calculated shipping rates sucessfully",
        data: {
          rates: shipping_rates
        }
      }
    else
      render json: {
        success: false,
        message: "Calculate shipping rates failure"
      }
    end
  end

  def search_by_name
    @listings = ListingSearchService.new(params[:q]).search
    respond_to do |format|
      format.json {render json: @listings}
    end
  end

  def add_packing_dimension
    @time_stamps = DateTime.current.strftime('%S%m')
    respond_to do |format|
      format.js {render 'add_packing_dimension.js.haml', layout: false}
    end
  end

  def remove_user_manual
    @listing.user_manual = nil
    @listing.save
    redirect_to edit_listing_path(@listing)
  end

  def add_accessories
    listing = Listing.find params[:id]
    position = listing.recommended_accessories.count + 1
    recommended_accessory = listing.recommended_accessories.create(listing_accessory_id: params[:listing_accessory_id], position: position)
  end

  def reorder_accessories
    listing = Listing.find params[:id]
    recommended_accessories = listing.recommended_accessories.order(position: :asc).to_a
    sorted = recommended_accessories.insert(params[:to].to_i, recommended_accessories.delete_at(params[:from].to_i))

    sorted.each_with_index do |item, index|
      item.update(position: index+1)
    end
  end

  def remove_accessory
    listing = Listing.find params[:id]
    listing.recommended_accessories.find_by(listing_accessory_id: params[:listing_accessory_id])&.destroy
    render json: {
      success: true
    }
  end

  def add_tab
    @listing.listing_tabs.create(title: 'New tab', tab_type: "new_tab", is_active: false)
    redirect_to edit_listing_path(@listing)
  end

  private

  def create_or_update_category_listings(category_ids, subcategory_ids, childcategory_ids)
    ListingUpdateCategoryService.new(category_ids.concat(subcategory_ids).concat(childcategory_ids).uniq, @listing)
                                .create_or_update_categories
  end

  def create_or_update_tabs listing, params
    params.keys.each do |key|
      tab = listing.listing_tabs.where(tab_type: key).last
      if tab
        if tab.tab_type == "new_tab"
          tab.update(params[key].merge({tab_type: params[key][:title].split(" ").join("_").downcase}))
        else
          tab.update(params[key])
        end
      else
        listing.listing_tabs.create(params[key].merge({tab_type: key}))
      end
    end
  end

  def create_or_update_listing_assessory listing, listing_accessory_attrs
    if listing.listing_accessory
      listing.listing_accessory.update(listing_accessory_attrs)
    else
      listing.create_listing_accessory(listing_accessory_attrs)
    end
  end

  def update_flash(old_availability:, new_availability:)
    case [new_availability.to_sym == :booking, old_availability.to_sym == :booking]
    when [true, false]
      t("layouts.notifications.listing_updated_availability_management_enabled")
    when [false, true]
      t("layouts.notifications.listing_updated_availability_management_disabled")
    else
      t("layouts.notifications.listing_updated_successfully")
    end
  end

  def create_bookable(community_uuid, listing_uuid, author_uuid)
    res = HarmonyClient.post(
      :create_bookable,
      body: {
        marketplaceId: community_uuid,
        refId: listing_uuid,
        authorId: author_uuid
      },
      opts: {
        max_attempts: 3
      })

    if !res[:success] && res[:data][:status] == 409
      Result::Success.new("Bookable for listing with UUID #{listing_uuid} already created")
    else
      res
    end
  end

  def select_shape(shapes, listing)
    if listing.listing_shape_id.nil?
      ListingShape.new(transaction_process_id: listing.transaction_process_id)
    elsif shapes.size == 1
      shapes.first
    else
      shapes.find { |shape| shape[:id] == listing.listing_shape_id }
    end
  end

  def form_locals(shape)
    @listing_presenter.listing_shape = shape
    {shape: shape}
  end

  def form_content
    make_listing_presenter

    if @listing.new_record?
      @listing.init_origin_location(@listing_presenter.new_listing_author.location)
    end
    @listing.category = @current_community.categories.find(params[:subcategory].presence || params[:category])
    @custom_field_questions = @listing.category.custom_fields
    @numeric_field_ids = numeric_field_ids(@custom_field_questions)

    shape = get_shape(Maybe(params)[:listing_shape].to_i.or_else(nil))
    process = @listing_presenter.get_transaction_process(community_id: @current_community.id, transaction_process_id: shape[:transaction_process_id])

    @listing.transaction_process_id = shape[:transaction_process_id]
    @listing.listing_shape_id = shape[:id]

    payment_type = @current_community.active_payment_types
    allow_posting, error_msg = payment_setup_status(
                     community: @current_community,
                     user: @listing_presenter.new_listing_author,
                     listing: @listing,
                     payment_type: payment_type,
                     process: process)

    if allow_posting
      render :partial => "listings/form/form_content", locals: form_locals(shape).merge(run_js_immediately: true)
    else
      render :partial => "listings/payout_registration_before_posting", locals: { error_msg: error_msg }
    end
  end

  # Ensure that only users with appropriate visibility settings can view the listing
  def ensure_authorized_to_view
    # If listing is not found (in this community) the find method
    # will throw ActiveRecord::NotFound exception, which is handled
    # correctly in production environment (404 page)
    @listing = Listing.find_by_url(params[:url]) || Listing.find_by_id(params[:url])

    raise ListingDeleted if @listing.deleted?

    unless Policy::ListingPolicy.new(@listing, @current_community, @current_user).visible?
      if @current_user
        flash[:error] = if @listing.closed?
          t("layouts.notifications.listing_closed")
        else
          t("layouts.notifications.you_are_not_authorized_to_view_this_content")
        end
        redirect_to search_path and return
      else
        session[:return_to] = request.fullpath
        flash[:warning] = t("layouts.notifications.you_must_log_in_to_view_this_content")
        redirect_to login_path and return
      end
    end
  end

  def change_follow_status(status)
    status.eql?("follow") ? @current_user.follow(@listing) : @current_user.unfollow(@listing)
    respond_to do |format|
      format.html {
        redirect_to @listing
      }
      format.js {
        render :follow, :layout => false
      }
    end
  end

  def is_authorized_to_post
    if new_listing_author != @current_user
      unless @current_user.has_admin_rights?(@current_community)
        flash[:error] = t("layouts.notifications.you_are_not_authorized_to_do_this")
        redirect_to root_path
      end
    end
    if @current_community.require_verification_to_post_listings?
      unless new_listing_author.has_admin_rights?(@current_community) || new_listing_author.community_membership.can_post_listings?
        redirect_to verification_required_listings_path
      end
    end
  end

  def numeric_field_ids(custom_fields)
    custom_fields.map do |custom_field|
      custom_field.with(:numeric) do
        custom_field.id
      end
    end.compact
  end

  def payment_setup_status(community:, user:, listing:, payment_type:, process:)
    case [payment_type, process]
    when matches([nil]),
         matches([__, :none])
      [true, ""]
    when matches([:paypal])
      can_post = PaypalHelper.community_ready_for_payments?(community.id)
      error_msg = make_error_msg(user, community)
      [can_post, error_msg]
    when matches([:stripe])
      can_post = StripeHelper.community_ready_for_payments?(community.id)
      error_msg = make_error_msg(user, community)
      [can_post, error_msg]
    when matches([[:paypal, :stripe]])
      can_post = StripeHelper.community_ready_for_payments?(community.id) || PaypalHelper.community_ready_for_payments?(community.id)
      error_msg = make_error_msg(user, community)
      [can_post, error_msg]
    else
      [true, ""]
    end
  end

  def make_error_msg(user, community)
    if user.has_admin_rights?(community)
      t("listings.new.community_not_configured_for_payments_admin",
        payment_settings_link: view_context.link_to(
          t("listings.new.payment_settings_link"),
          admin_payment_preferences_path()))
        .html_safe
    else
      t("listings.new.community_not_configured_for_payments",
        contact_admin_link: view_context.link_to(
          t("listings.new.contact_admin_link_text"),
          new_user_feedback_path))
        .html_safe
    end
  end

  def get_shape(listing_shape_id)
    @current_community.shapes.find(listing_shape_id)
  end

  # Create image sizes that might be missing
  # from a reopened listing
  def reprocess_missing_image_styles(listing)
    listing.listing_image_ids.each { |image_id|
      Delayed::Job.enqueue(CreateSquareImagesJob.new(image_id))
    }
  end

  def make_listing_presenter
    @listing_presenter = ListingPresenter.new(@listing, @current_community, params, @current_user)
  end

  def notify_about_new_listing
    Delayed::Job.enqueue(ListingCreatedJob.new(@listing.id, @current_community.id))
    if @current_community.follow_in_use?
      Delayed::Job.enqueue(NotifyFollowersJob.new(@listing.id, @current_community.id), :run_at => NotifyFollowersJob::DELAY.from_now)
    end

    flash[:notice] = t(
      "layouts.notifications.listing_created_successfully",
      :new_listing_link => view_context.link_to(t("layouts.notifications.create_new_listing"),new_listing_path)
    ).html_safe

    # Onboarding wizard step recording
    state_changed = Admin::OnboardingWizard.new(@current_community.id)
      .update_from_event(:listing_created, @listing)
    if state_changed
      record_event(flash, "km_record", {km_event: "Onboarding listing created"}, AnalyticService::EVENT_LISTING_CREATED)

      flash[:show_onboarding_popup] = true
    end
  end

  def create_booking(shape, listing_uuid)
    if shape.present?
      if shape.booking_per_hour?
        true
      elsif APP_CONFIG.harmony_api_in_use && shape.booking?
        harmony_service.create_bookable(@current_community.uuid_object, listing_uuid, @current_user.uuid_object).success
      else
        true
      end
    else
      true
    end
  end

  def new_listing_author
    @new_listing_author ||=
      if params[:person_id].present? &&
         @current_user.has_admin_rights?(@current_community)
        @current_community.members.find_by!(username: params[:person_id])
      else
        @current_user
      end
  end

  def set_sessions
    session[:shipping] ||= {}
    session[:shipping][:fedex] = []
  end

  def transaction_items_service
    if @current_user && @current_user.starter_transactions.last
      TransactionItemsService.new(@current_user.starter_transactions.last, session, @current_user)
    else
      if session[:transaction] && session[:transaction][:transaction_id]
        transaction = Transaction.find_by(id: session[:transaction][:transaction_id])
        TransactionItemsService.new(transaction, session, nil)
      end
    end
  end

  def harmony_service
    HarmonyService.new
  end
end
