require 'csv'
class ExportCompletedTransactionsJob < Struct.new(:current_user_id, :community_id, :export_task_id)
  include DelayedAirbrakeNotification

  # This before hook should be included in all Jobs to make sure that the service_name is
  # correct as it's stored in the thread and the same thread handles many different communities
  # if the job doesn't have host parameter, should call the method with nil, to set the default service_name
  def before(job)
    # Set the correct service name to thread for I18n to pick it
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end

  def perform
    community = Community.find(community_id)
    export_task = ExportTaskResult.find(export_task_id)
    export_task.update(status: 'started')

    # conversations = Transaction.for_community_sorted_by_activity(community.id, 'desc', nil, nil, true)
    conversations = Transaction.complete.order(order_number: :desc)
    csv_rows = generate_csv_for(conversations)
    csv_content = csv_rows.join("")
    marketplace_name = community.use_domain ? community.domain : community.ident
    filename = "#{marketplace_name}-transactions-#{Time.zone.today}-#{export_task.token}.csv"
    export_task.original_filename = filename
    export_task.original_extname = File.extname(filename).delete('.')
    export_task.update(status: 'finished', file: FakeFileIO.new(filename, csv_content))
  end

  def generate_csv_for(transactions)
    # first line is column names
    yielder = []
    yielder << %w{
      name
      email
      financial_status
      fulfillment_status
      fulfilled_at
      payment_reference
      accepts_marketing
      currency
      subtotal
      shipping
      taxes
      total
      discount_code
      discount_amount
      shipping_method
      created_at
      lineitem_quantity
      lineitem_name
      lineitem_price
      lineitem_compare_at_price
      lineitem_sku
      lineitem_requires_shipping
      lineitem_taxable
      lineitem_fulfillment_status
      billing_name
      billing_street
      billing_address1
      billing_address2
      billing_company
      billing_city
      billing_zip
      billing_province
      billing_country
      billing_phone
      shipping_name
      shipping_street
      shipping_address1
      shipping_address2
      shipping_company
      shipping_city
      shipping_zip
      shipping_province
      shipping_country
      shipping_phone
      notes
      note_Attributes
      cancelled_at
      payment_method
      refunded_amount
      vendor
      outstanding_balance
      tax_1_name
      tax_1_value
      tax_2_name
      tax_2_value
      phone
    }.to_csv(force_quotes: true)
    transactions.each do |transaction|
      @calculate_money_service = TransactionMoneyCalculation.new(transaction, {}, nil)
      shipping_address = transaction.shipping_address
      next unless shipping_address
      billing_address = transaction.billing_address
      stripe_payment = transaction.stripe_payments.standard.last
      refund_payments = transaction.stripe_payments.refund
      tax =  Tax.find_by(province: shipping_address.get_state_or_province)
      yielder << [
        transaction.order_number,
        shipping_address.email,
        transaction.current_state,
        transaction.fulfilled? ? "fulfilled" : "unfulfilled",
        transaction.updated_at && I18n.l(transaction.created_at, format: '%Y-%m-%d %H:%M:%S'),
        stripe_payment ? stripe_payment.stripe_payment_intent_id : "",
        "yes",
        "CAD",
        MoneyViewUtils.to_CAD(@calculate_money_service.listings_subtotal),
        transaction.shipper ? transaction.shipper.amount : 0,
        MoneyViewUtils.to_CAD(@calculate_money_service.get_tax_fee),
        MoneyViewUtils.to_CAD(@calculate_money_service.final_price),
        transaction.promo_code ? transaction.promo_code.code : "",
        MoneyViewUtils.to_CAD(@calculate_money_service.get_discount_for_all_products_cart),
        transaction.shipper ? transaction.shipper.service_delivery : "",
        transaction.created_at && I18n.l(transaction.created_at, format: '%Y-%m-%d %H:%M:%S'),
        transaction.transaction_items.pluck(:quantity),
        transaction.transaction_items.map {|item| item.listing ? item.listing.title : "No name"},
        transaction.transaction_items.pluck(:price_cents),
        "",
        transaction.transaction_items.map {|item| item.listing ? item.listing.sku : "No sku"},
        0,
        1,
        transaction.fulfilled? ? "fulfilled" : "unfulfilled",
        billing_address.fullname,
        billing_address.get_street1,
        "",
        "",
        billing_address.company,
        billing_address.get_city,
        billing_address.get_postal_code,
        CANADA_PROVINCES.key(billing_address.get_state_or_province),
        billing_address.country,
        billing_address.phone,
        shipping_address.fullname,
        shipping_address.get_street1,
        "",
        "",
        shipping_address.company,
        shipping_address.get_city,
        shipping_address.get_postal_code,
        CANADA_PROVINCES.key(shipping_address.get_state_or_province),
        shipping_address.country,
        shipping_address.phone,
        transaction.instructions_from_seller,
        "",
        transaction.is_cancelled? ? transaction.updated_at && I18n.l(transaction.created_at, format: '%Y-%m-%d %H:%M:%S') : "",
        'Stripe',
        refund_payments.pluck(:sum_cents).sum,
        "",
        "",
        tax.tax_rates[:GST] ? "GST #{tax.tax_rates[:GST]} %" : "",
        tax.tax_rates[:GST] ? MoneyViewUtils.to_CAD(@calculate_money_service.calculate_tax_fee_base_on_percent(tax.tax_rates[:GST])) : "",
        tax.tax_rates[:PST] ? "PST #{tax.tax_rates[:PST]} %" : "",
        tax.tax_rates[:PST] ? MoneyViewUtils.to_CAD(@calculate_money_service.calculate_tax_fee_base_on_percent(tax.tax_rates[:PST])) : "",
      ].to_csv(force_quotes: true)
    end
    yielder
  end
end