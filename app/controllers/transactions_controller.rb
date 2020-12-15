class TransactionsController < ApplicationController

  before_action only: [:show] do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_inbox")
  end

  # before_action only: [:new] do |controller|
  #   fetch_data(params[:listing_id]).on_success do |listing_id, listing_model, _, process|
  #     record_event(
  #       flash,
  #       "BuyButtonClicked",
  #       { listing_id: listing_id,
  #         listing_uuid: listing_model.uuid_object.to_s,
  #         payment_process: process.process,
  #         user_logged_in: @current_user.present?
  #       })
  #   end
  # end

  before_action :find_transaction_by_uuid, only: [
    :update_promo_code,
    :change_shipping_selection,
    :shipment,
    :checkout,
    :change_state_shipping_form,
    :payment,
    :thank_you
  ]

  before_action :find_transaction_by_id, only: [:order_details]

  before_action :calculate_money_service, only: [:shipment, :checkout, :change_state_shipping_form, :payment, :thank_you, :order_details]

  before_action except: [
    :checkout,
    :create,
    :shipment,
    :change_shipping_selection,
    :update_promo_code,
    :change_state_shipping_form,
    :payment,
    :thank_you] do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_do_a_transaction")
  end

  before_action :checkout_setting, only: [:checkout]

  TransactionForm = EntityUtils.define_builder(
    [:listing_id, :fixnum, :to_integer, :mandatory],
    [:message, :string],
    [:quantity, :fixnum, :to_integer, default: 1],
    [:start_on, transform_with: ->(v) { Maybe(v).map { |d| TransactionViewUtils.parse_booking_date(d) }.or_else(nil) }],
    [:end_on, transform_with: ->(v) { Maybe(v).map { |d| TransactionViewUtils.parse_booking_date(d) }.or_else(nil) }]
  )

  before_action :ensure_can_countinue_transactions, only: [:checkout, :shipment, :payment]

  def new
    # Result.all(
    #   -> {
    #     fetch_data(params[:listing_id])
    #   },
    #   ->((listing_id, listing_model)) {
    #     ensure_can_start_transactions(listing_model: listing_model, current_user: @current_user, current_community: @current_community)
    #   }
    # ).on_success { |((listing_id, listing_model, author_model, process, gateway))|
    #   transaction_params = HashUtils.symbolize_keys(
    #     {listing_id: listing_model.id}
    #     .merge(params.slice(:start_on, :end_on, :quantity, :delivery, :start_time, :end_time, :per_hour).permit!)
    #   )

    #   case [process.process, gateway]
    #   when matches([:none])
    #     render_free(listing_model: listing_model, author_model: author_model, community: @current_community, params: transaction_params)
    #   when matches([:preauthorize, :paypal]), matches([:preauthorize, :stripe]), matches([:preauthorize, [:paypal, :stripe]])
    #     redirect_to initiate_order_path(transaction_params)
    #   else
    #     opts = "listing_id: #{listing_id}, payment_gateway: #{gateway}, payment_process: #{process}, booking: #{booking}"
    #     raise ArgumentError.new("Cannot find new transaction path to #{opts}")
    #   end
    # }.on_error { |error_msg, data|
    #   flash[:error] = Maybe(data)[:error_tr_key].map { |tr_key| t(tr_key) }.or_else("Could not start a transaction, error message: #{error_msg}")
    #   redirect_to(session[:return_to_content] || root)
    # }
  end

  def create
    # if @current_user
    #   if @current_user.has_a_pending_transaction?
    #     update_transaction_with_current_user(@current_user.pending_transaction, params)
    #   elsif session[:transaction] && session[:transaction][:transaction_id]
    #     # check if transaction is pending
    #     @transaction = Transaction.find_by(id: session[:transaction][:transaction_id])
    #     if @transaction.completed?
    #       @transaction = create_transaction_with_current_user(params)
    #     else
    #       @transaction = update_transaction_with_current_user(@transaction, params)
    #     end
    #   else
    #     @transaction = create_transaction_with_current_user(params)
    #   end
    # else
    #   if session[:transaction] && session[:transaction][:transaction_id]
    #     @transaction =  Transaction.find_by(id: session[:transaction][:transaction_id])
    #     if @transaction && !@transaction.completed?
    #       @transaction = update_transaction_without_current_user(@transaction, params)
    #     else
    #       @transaction = create_transaction_without_current_user(params)
    #     end
    #     return render json: {redirect_url: checkout_transaction_path(@transaction.uuid_object)}
    #   else
    #     @transaction = create_transaction_without_current_user(params)
    #   end
    # end

    if @current_user
      @transaction = create_transaction_with_current_user(params)
    else
      @transaction = create_transaction_without_current_user(params)
    end

    respond_to do |format|
      format.html
      format.json { render json: {redirect_url: checkout_transaction_path(@transaction.uuid_object)} }
    end
  end

  def create_transaction_with_current_user params
    @transaction = transaction_service.create(session, params)
    @transaction.update(starter_id: @current_user.id)
    @transaction
  end

  def create_transaction_without_current_user params
    @transaction = transaction_service.create(session, params)
    session[:transaction] = {transaction_id: @transaction.id}
    @transaction
  end

  # def update_transaction_with_current_user transaction, params
  #   @transaction = transaction_service.update(session, transaction, params[:code], params[:instructions])
  #   @transaction.update(starter_id: @current_user.id)
  #   @transaction
  # end

  # def update_transaction_without_current_user transaction, params
  #   @transaction = transaction_service.update(session, transaction, params[:code], params[:instructions])
  #   session[:transaction] = {transaction_id: @transaction.id}
  #   @transaction
  # end

  def show
    @transaction = @current_community.transactions.find(params[:id])
    m_admin = @current_user.has_admin_rights?(@current_community)
    m_participant = @current_user.id == @transaction.starter_id || @current_user.id == @transaction.listing_author_id

    unless m_admin || m_participant
      flash[:error] = t("layouts.notifications.you_are_not_authorized_to_view_this_content")
      return redirect_to search_path
    end

    role =
      if m_participant
        :participant
      elsif m_admin
        :admin
      end

    @conversation = @transaction.conversation
    @listing = @transaction.listing

    messages_and_actions = TransactionViewUtils.merge_messages_and_transitions(
      TransactionViewUtils.conversation_messages(@conversation.messages, @current_community.name_display_type),
      TransactionViewUtils.transition_messages(@transaction, @conversation, @current_community.name_display_type))

    @transaction.mark_as_seen_by_current(@current_user.id)

    is_author = m_admin || @transaction.listing_author_id == @current_user.id

    render "transactions/show", locals: {
      messages: messages_and_actions.reverse,
      conversation_other_party: @conversation.other_party(@current_user),
      is_author: is_author,
      role: role,
      message_form: Message.new({sender_id: @current_user.id, conversation_id: @conversation.id}),
      message_form_action: person_message_messages_path(@current_user, :message_id => @conversation.id),
      price_break_down_locals: price_break_down_locals(@transaction, @conversation)
    }
  end

  def created
    proc_status = transaction_service.finalize_create(
      community_id: @current_community.id,
      transaction_id: params[:transaction_id],
      force_sync: false)

    unless proc_status[:success]
      flash[:error] = t("error_messages.booking.booking_failed_payment_voided")
      return redirect_to search_path
    end

    tx_fields = proc_status.dig(:data, :transaction_service_fields) || {}
    process_token = tx_fields[:process_token]
    process_completed = tx_fields[:completed]

    if process_token.present?
      redirect_url = transaction_finalize_processed_path(process_token)

      if process_completed
        redirect_to redirect_url
      else
        # Operation was performed asynchronously

        # We're using here the same PayPal spinner, although we could
        # create a new one for TransactionService.
        render "paypal_service/success", layout: false, locals: {
                 op_status_url: transaction_op_status_path(process_token),
                 redirect_url: redirect_url
               }
      end
    else
      handle_finalize_proc_result(proc_status)
    end
  end

  def finalize_processed
    process_token = params[:process_token]

    proc_status = transaction_process_tokens.get_status(UUIDTools::UUID.parse(process_token))
    unless (proc_status[:success] && proc_status[:data][:completed])
      return redirect_to error_not_found_path
    end

    handle_finalize_proc_result(proc_status[:data][:result])
  end

  def transaction_op_status
    process_token = params[:process_token]

    resp = Maybe(process_token)
             .map { |ptok|
               uuid = UUIDTools::UUID.parse(process_token)
               transaction_process_tokens.get_status(uuid)
             }
             .select(&:success)
             .data
             .or_else(nil)

    if resp
      render json: process_resp_to_json(resp)
    else
      head :not_found
    end
  end

  def person_with_url(person)
    {
      person: person_entity,
      url: person_path(username: person.username),
      display_name: PersonViewUtils.person_display_name(person, @current_community.name_display_type)
    }
  end

  def check_booking_date_session_was_change transaction
    if transaction.booking
      if transaction.booking.start_on != datetime_service.convert_date(session[:booking][:start_date]) ||
        transaction.booking.end_on != datetime_service.convert_date(session[:booking][:end_date])
          transaction.booking.update(
          start_on: datetime_service.convert_date(session[:booking][:start_date]),
          end_on: datetime_service.convert_date(session[:booking][:end_date])
        )
      end
    else
      transaction.create_booking(
        start_on: datetime_service.convert_date(session[:booking][:start_date]),
        end_on: datetime_service.convert_date(session[:booking][:end_date])
      )
    end
  end

  def checkout
    update_transaction_items(@transaction)
    check_booking_date_session_was_change(@transaction)
    @default_shipping_fee = 0
    if @current_user
      if @current_user.shipping_address
        @shipping_address = update_shipping_address_with_current_user_params(@transaction, @current_user.shipping_address)
      else
        @shipping_address = create_shipping_address_with_current_user_params(@transaction)
      end
    else
      if @transaction.shipping_address
        @shipping_address = @transaction.shipping_address
      else
        @shipping_address = create_shipping_address_without_current_user @transaction
      end
    end
    if @transaction.draft_order? && @transaction.shipping_address
      @shipping_address = @transaction.shipping_address
    end
    #TODO: fix this function
    # add_padding_time_to_listing(@transaction.transaction_items.pluck(:listing_id), @transaction.booking, @current_community)
  end

  def add_padding_time_to_listing listing_ids, booking, community
    padding_before_dates = (booking.start_on - community.padding_time_before.days...booking.start_on).to_a
    padding_after_dates = (booking.end_on.tomorrow...booking.end_on.tomorrow + community.padding_time_after.days).to_a
    padding_time_array = (padding_after_dates + padding_before_dates).uniq.sort.map{|date| date.to_formatted_s(:iso8601)}.to_s.remove("[", "]").gsub!(/\"/, '\'')
    Listing.where(id: listing_ids).each do |listing|
      listing.update(manually_blocked_dates: padding_time_array) if listing.available_quantity <= 1
    end
  end

  def create_shipping_address_without_current_user transaction
    if session[:booking][:start_date] == get_today
      shipping_address = TransactionAddress.create(OFFICE_ADDRESS)
    else
      shipping_address = TransactionAddress.new
    end
    transaction.update(shipping_address_id: shipping_address.id)
    shipping_address
  end

  def create_shipping_address_with_current_user_params transaction
    if session[:booking][:start_date] == get_today
      shipping_address = @current_user.transaction_addresses.create(OFFICE_ADDRESS)
    else
      shipping_address = TransactionAddress.new
    end
    transaction.update(shipping_address_id: shipping_address.id)
    shipping_address
  end

  def update_shipping_address_with_current_user_params transaction, shipping_address
    if session[:booking][:start_date] == get_today
      shipping_address.update_columns(OFFICE_ADDRESS)
    else
      shipping_address.update(EMPTY_SHIPPING_ADDRESS)
    end
    transaction.update(shipping_address_id: @current_user.shipping_address.id)
    shipping_address
  end

  def shipment
    return redirect_to payment_transaction_path(@transaction.uuid_object)
    return unless @transaction.transaction_items.any?
    listing_ids = @transaction.transaction_items.pluck(:listing_id)
    listings = Listing.where(id: listing_ids)
    zipcode = @transaction.shipping_address.postal_code
    return unless zipcode

    listings.each do |listing|
      if listing.packing_dimensions.blank?
        # TODO: create packing_dimension only for test, remove this line when app release
        PackingDimension.create(height: 10, length:10, width: 10, weight: 10, listing_id: listing.id)
        # @message = "The listing has not dimensions to calculate"
      end
    end

    total_quantity = @transaction.total_quantity
    @shipping_address = @transaction.shipping_address
    @state = @shipping_address.state_or_province
    @promo_code = @transaction.promo_code ? @transaction.promo_code.code : nil
    result = ShippingRatesService.get_shipping_rates_for_cart_page(listing_ids, zipcode, total_quantity)
    if result[:success]
      @shipping_selection = result[:shipping_selection]
      session[:shipping][:fedex] = @shipping_selection
      if @transaction.shipper
        if @transaction.will_pickup?
          shipper_params = {service_delivery: 'free', amount: 0, service_type: "free", service_name: "free"}
          @transaction.shipper.update(shipper_params)
        end
        @default_shipping_fee = @transaction.shipper.amount
      else
        if @transaction.will_pickup?
          shipper_params = {service_delivery: 'free', amount: 0, service_type: "free", service_name: "free"}
        else
          shipper_params = {
            service_delivery: 'fedex',
            service_type: @shipping_selection.first['service_type'],
            service_name: @shipping_selection.first['service_name'],
            amount: @shipping_selection.first['total_charge']['amount'],
            currency: @shipping_selection.first['total_charge']['currency'],
          }
        end
        @transaction.create_shipper(shipper_params)
        @default_shipping_fee = @transaction.shipper.amount
      end
    else
      flash[:notice] = result[:message]
      return redirect_to checkout_transaction_path(@transaction.uuid_object)
    end
  end

  def change_state_shipping_form
    @state = params[:state]
    respond_to do |format|
      format.html
      format.js { render :layout => false}
    end
  end

  def change_shipping_selection
    @state = @transaction.shipping_address.state_or_province
    if params[:shipping_type] == "free"
      @default_shipping_fee = 0
      shipper_params = {
        service_delivery: 'free',
        service_type: "free",
        service_name: "free",
        amount: 0,
        currency: 'CAD',
      }
      @transaction.shipping_address.update_columns(OFFICE_ADDRESS)
    else
      @shipping_selection = session[:shipping][:fedex].select{|s| s["service_type"] == params[:shipping_type]}
      @default_shipping_fee = @shipping_selection.first['total_charge']['amount']
      shipper_params = {
        service_delivery: @shipping_selection.first['shipper_slug'],
        service_type: @shipping_selection.first['service_type'],
        service_name: @shipping_selection.first['service_name'],
        amount: @shipping_selection.first['total_charge']['amount'],
        currency: @shipping_selection.first['total_charge']['currency'],
      }
    end
    @transaction.shipper.update(shipper_params)
    calculate_money_service(@transaction)
    respond_to do |format|
      format.html
      format.js {render layout: false}
    end
  end

  def update_promo_code
    @promo_code = PromoCode.find_by(code: params[:promo_code])
    if @promo_code
      promo_code_service(@promo_code)
      @result = @promo_code_service.check_if_promo_code_can_use
      session[:promo_code] = {code: @promo_code.code}
      @transaction.update(promo_code_id: @promo_code.id)
    else
      @result = {success: false, message: 'This code is invalid or already used.'}
    end
    @state = @transaction.shipping_address.state_or_province
    @default_shipping_fee = @transaction.shipper.amount
    calculate_money_service(@transaction)
    respond_to do |format|
      format.html
      format.js {render layout: false}
    end
  end

  def payment
    @shipping_address = @transaction.shipping_address
    if @current_user
      if @current_user.billing_address
        @billing_address = @current_user.billing_address
      else
        @billing_address = @current_user.transaction_addresses.build
      end
    else
      if session[:billing_address]
        @billing_address = TransactionAddress.new(session[:billing_address])
      else
        @billing_address = TransactionAddress.new
      end
    end
    if @transaction.draft_order?
      @default_shipping_fee = @transaction.draft_order_shipping_fee&.price_cents
      @billing_address = @transaction.billing_address
    else
      @default_shipping_fee = @transaction.shipper.amount
    end
  end

  def thank_you
    @shipping_address = @transaction.shipping_address
    @billing_address = @transaction.billing_address
    @state = @transaction.shipping_address.state_or_province
    if @transaction.draft_order?
      @default_shipping_fee = @transaction.draft_order_shipping_fee&.price_cents
      @billing_address = @transaction.billing_address
    else
      @default_shipping_fee = @transaction.shipper.amount
    end
    @helping_request = @transaction.helping_requests.build
  end

  def order_details

  end

  private

  def update_transaction_items transaction
    return if transaction.draft_order?
    keys_id = session[:cart].keys
    session[:cart].each do |listing_id, quantity|
      item = transaction.transaction_items.find_by(listing_id: listing_id)
      coverage_type = (session[:coverage] && session[:coverage][listing_id.to_s]) ? session[:coverage][listing_id.to_s] : "movri_coverage"
      if item
        item.update(quantity: quantity, coverage_type: coverage_type)
      else
        listing = Listing.find_by(id: listing_id)
        transaction.create_transaction_item listing, quantity, transaction.booking.duration, coverage_type
      end
    end
    # remove item not in cart
    transaction.transaction_items.where.not(listing_id: keys_id).delete_all
  end

  def ensure_can_countinue_transactions
    if @transaction.completed?
      flash[:error] = "The transaction is already completed."
      return redirect_to cart_path
    end
    if @transaction.is_overweight?
      flash[:error] = "Please contact us for this. This package is overweight. We'd love to help you with completing the transaction."
      return redirect_to cart_path
    end

    if checkout_setting.only_guest? && @current_user
      flash[:error] = "Only guest can continue with transaction."
      return redirect_to cart_path
    end
    if checkout_setting.only_accounts? && !@current_user
      flash[:error] = t("layouts.notifications.you_must_log_in_to_do_a_transaction")
      return redirect_to login_path
    end
  end

  def find_transaction_by_uuid
    @transaction = Transaction.find_by(uuid: uuid_to_raw(params[:uuid]))
  end

  def find_transaction_by_id
    @transaction = Transaction.find_by(id: params[:id])
  end

  def handle_finalize_proc_result(response)
    response_data = response[:data] || {}

    if response[:success]
      tx = response_data[:transaction]

      record_event(
        flash,
        "TransactionCreated",
        { listing_id: tx.listing_id,
          listing_uuid: UUIDUtils.parse_raw(tx.listing_uuid).to_s,
          transaction_id: tx.id,
          payment_process: tx.payment_process })

      redirect_to person_transaction_path(person_id: @current_user.id, id: tx.id)
    else
      listing_id = response_data[:listing_id]

      flash[:error] =
        case response_data[:reason]
        when :connection_issue
          t("error_messages.booking.booking_failed_payment_voided")
        when :double_booking
          t("error_messages.booking.double_booking_payment_voided")
        else
          t("error_messages.booking.booking_failed_payment_voided")
        end

      redirect_to person_listing_path(person_id: @current_user.id, id: listing_id)
    end
  end

  def ensure_can_start_transactions(listing_model:, current_user:, current_community:)
    error =
      if listing_model.closed?
        "layouts.notifications.you_cannot_reply_to_a_closed_offer"
      elsif listing_model.author == current_user
       "layouts.notifications.you_cannot_send_message_to_yourself"
      elsif !Policy::ListingPolicy.new(listing_model, current_community, current_user).visible?
        "layouts.notifications.you_are_not_authorized_to_view_this_content"
      end

    if error
      Result::Error.new(error, {error_tr_key: error})
    else
      Result::Success.new
    end
  end

  def after_create_flash(process:)
    case process.process
    when :none
      t("layouts.notifications.message_sent")
    else
      raise NotImplementedError.new("Not implemented for process #{process}")
    end
  end

  def after_create_redirect(process:, starter_id:, transaction:)
    case process.process
    when :none
      person_transaction_path(person_id: starter_id, id: transaction[:id])
    else
      raise NotImplementedError.new("Not implemented for process #{process}")
    end
  end

  def after_create_actions!(process:, transaction:, community_id:)
    case process.process
    when :none
      # TODO Do I really have to do the state transition here?
      # Shouldn't it be handled by the TransactionService
      TransactionService::StateMachine.transition_to(transaction[:id], "free")

      transaction = Transaction.find(transaction[:id])

      Delayed::Job.enqueue(MessageSentJob.new(transaction.conversation.messages.last.id, community_id))
    else
      raise NotImplementedError.new("Not implemented for process #{process}")
    end
  end

  # Fetch all related data based on the listing_id
  #
  # Returns: Result::Success([listing_id, listing_model, author, process, gateway])
  #
  def fetch_data(listing_id)
    Result.all(
      -> {
        if listing_id.nil?
          Result::Error.new("No listing ID provided")
        else
          Result::Success.new(listing_id)
        end
      },
      ->(l_id) {
        Maybe(@current_community.listings.where(id: l_id).first)
          .map     { |listing_model| Result::Success.new(listing_model) }
          .or_else { Result::Error.new("Cannot find listing with id #{l_id}") }
      },
      ->(_, listing_model) {
        Result::Success.new(listing_model.author)
      },
      ->(_, listing_model, *rest) {
        TransactionService::API::Api.processes.get(community_id: @current_community.id, process_id: listing_model.transaction_process_id)
      },
      ->(*) {
        Result::Success.new(@current_community.active_payment_types)
      }
    )
  end

  def validate_form(form_params, process)
    if process.process == :none && form_params[:message].blank?
      Result::Error.new("Message cannot be empty")
    else
      Result::Success.new
    end
  end

  def price_break_down_locals(tx, conversation)
    if tx.payment_process == :none && tx.unit_price.cents == 0 || conversation.starting_page == Conversation::LISTING
      nil
    else
      localized_unit_type = tx.unit_type.present? ? ListingViewUtils.translate_unit(tx.unit_type, tx.unit_tr_key) : nil
      localized_selector_label = tx.unit_type.present? ? ListingViewUtils.translate_quantity(tx.unit_type, tx.unit_selector_tr_key) : nil
      booking = !!tx.booking
      booking_per_hour = tx.booking&.per_hour
      quantity = tx.listing_quantity
      show_subtotal = !!tx.booking || quantity.present? && quantity > 1 || tx.shipping_price.present?
      total_label = (tx.payment_process != :preauthorize) ? t("transactions.price") : t("transactions.total")
      payment = TransactionService::Transaction.payment_details(tx)

      TransactionViewUtils.price_break_down_locals({
        listing_price: tx.unit_price,
        localized_unit_type: localized_unit_type,
        localized_selector_label: localized_selector_label,
        booking: booking,
        start_on: booking ? tx.booking.start_on : nil,
        end_on: booking ? tx.booking.end_on : nil,
        duration: booking ? tx.listing_quantity : nil,
        quantity: quantity,
        subtotal: show_subtotal ? tx.item_total : nil,
        total: Maybe(tx.payment_total).or_else(payment[:total_price]),
        seller_gets: Maybe(tx.payment_total).or_else(payment[:total_price]) - tx.commission - tx.buyer_commission,
        fee: tx.commission,
        shipping_price: tx.shipping_price,
        total_label: total_label,
        unit_type: tx.unit_type,
        per_hour: booking_per_hour,
        start_time: booking_per_hour ? tx.booking.start_time : nil,
        end_time: booking_per_hour ? tx.booking.end_time : nil,
        buyer_fee: tx.buyer_commission
      })
    end
  end

  def render_free(listing_model:, author_model:, community:, params:)
    listing = {
      id: listing_model.id,
      title: listing_model.title,
      action_button_label: t(listing_model.action_button_tr_key)
    }
    author = {
      display_name: PersonViewUtils.person_display_name(author_model, community),
      username: author_model.username
    }

    unit_type = listing_model.unit_type.present? ? ListingViewUtils.translate_unit(listing_model.unit_type, listing_model.unit_tr_key) : nil
    localized_selector_label = listing_model.unit_type.present? ? ListingViewUtils.translate_quantity(listing_model.unit_type, listing_model.unit_selector_tr_key) : nil
    booking_start = Maybe(params)[:start_on].map { |d| TransactionViewUtils.parse_booking_date(d) }.or_else(nil)
    booking_end = Maybe(params)[:end_on].map { |d| TransactionViewUtils.parse_booking_date(d) }.or_else(nil)
    booking = date_selector?(listing_model)

    quantity = calculate_quantity(tx_params: {
                                    start_on: booking_start,
                                    end_on: booking_end,
                                    quantity: TransactionViewUtils.parse_quantity(params[:quantity])
                                  },
                                  is_booking: booking,
                                  unit: listing_model.unit_type)

    total_label = t("transactions.price")

    m_price_break_down = Maybe(listing_model).select { |l_model| l_model.price.present? }.map { |l_model|
      TransactionViewUtils.price_break_down_locals(
        {
          listing_price: l_model.price,
          localized_unit_type: unit_type,
          localized_selector_label: localized_selector_label,
          booking: booking,
          start_on: booking_start,
          end_on: booking_end,
          duration: quantity,
          quantity: quantity,
          subtotal: quantity != 1 ? l_model.price * quantity : nil,
          total: l_model.price * quantity,
          shipping_price: nil,
          total_label: total_label,
          unit_type: l_model.unit_type
        })
    }

    # render "transactions/new", locals: {
    #          listing: listing,
    #          author: author,
    #          action_button_label: t(listing_model.action_button_tr_key),
    #          m_price_break_down: m_price_break_down,
    #          booking_start: booking_start,
    #          booking_end: booking_end,
    #          quantity: quantity,
    #          form_action: person_transactions_path(person_id: @current_user, listing_id: listing_model.id)
    #        }
  end

  def date_selector?(listing)
    [:day, :night].include?(listing.quantity_selector&.to_sym)
  end

  def calculate_quantity(tx_params:, is_booking:, unit:)
    if is_booking
      DateUtils.duration(tx_params[:start_on], tx_params[:end_on])
    else
      tx_params[:quantity] || 1
    end
  end

  def process_resp_to_json(resp)
    if resp[:completed]
      {
        completed: true,
        result: {
          success: resp[:result][:success],
          data: {
            redirect_url: resp.dig(:result, :data, :redirect_url)
          }
        }
      }
    else
      { completed: false }
    end
  end

  def calculate_money_service(transaction=nil)
    transaction = transaction || @transaction
    @calculate_money = TransactionMoneyCalculation.new(transaction, session, @current_user)
  end

  def checkout_setting
    @checkout_setting = CheckoutSetting.last
  end

  def transaction_service
    TransactionService::Transaction
  end

  def datetime_service
    DatetimeService
  end

  def transaction_process_tokens
    TransactionService::API::Api.process_tokens
  end

  def promo_code_service(promo_code)
    @promo_code_service ||= PromoCodeService.new(promo_code, session, @current_user)
  end
end