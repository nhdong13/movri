validateShippingAddressForm = ->
  $(".desktop-shipping-address").validate
    errorPlacement: (error, element) ->
      if $(element).attr("id") == "term"
        $(element).parent().css("border-color", "red")
      else
        $(element).css("border-color", "red")
      $('.fullfill-fields-form-message').show()
      true
    rules:
      'transaction_address[email]':
        required: true
        emailFormat: true
      'transaction_address[first_name]':
        required: true
        minlength: 2
      'transaction_address[last_name]':
        required: true
        minlength: 2
      'transaction_address[street1]':
        required: true
      'transaction_address[city]':
        required: true
      'transaction_address[postal_code]':
        required: true
        minlength: 6
        cdnPostal: true
      'term':
        required: true

validateBillingAddressForm = ->
  $(".desktop-payment-form").validate
    errorPlacement: (error, element) ->
      $(element).css("border-color", "red")
      $('.fullfill-fields-form-message').show()
      true
    rules:
      'transaction_address[first_name]':
        required: true
        minlength: 2
      'transaction_address[last_name]':
        required: true
        minlength: 2
      'transaction_address[street1]':
        required: true
      'transaction_address[city]':
        required: true
      'transaction_address[postal_code]':
        required: true
        minlength: 6
        cdnPostal: true
      'transaction_address[phone]':
        required: true

validateMobileShippingAddressForm = ->
  $(".mobile-shipping-address").validate
    errorPlacement: (error, element) ->
      if $(element).attr("id") == "term"
        $(element).parent().css("border-color", "red")
      else
        $(element).css("border-color", "red")
      $('.fullfill-fields-form-message').show()
      true
    rules:
      'transaction_address[email]':
        required: true
        emailFormat: true
      'transaction_address[first_name]':
        required: true
        minlength: 2
      'transaction_address[last_name]':
        required: true
        minlength: 2
      'transaction_address[street1]':
        required: true
      'transaction_address[city]':
        required: true
      'transaction_address[postal_code]':
        required: true
        minlength: 6
        cdnPostal: true
      'term':
        required: true

onInputRequiredShippingFormField = ->
  $('.transaction-address-req-field').change ->
    if $(this).valid()
      $(this).animate({backgroundColor:'#e8f0fe'}, 500);
      $(this).parent().find('.fa-check').css("display", 'inline-block');
    else
      $(this).parent().find('.fa-check').hide();
      $(this).animate({backgroundColor:'white'}, 500);

onInputUnrequiredShippingFormField = ->
  $('.transaction-address-field').change ->
    if $(this).val() != ""
      $(this).animate({backgroundColor:'#e8f0fe'}, 500);
      $(this).parent().find('.fa-check').css("display", 'inline-block');
    else
      $(this).parent().find('.fa-check').hide();
      $(this).animate({backgroundColor:'white'}, 500);

onChangeState = ->
  $('.shipping-address-state').change ->
    uuid = $('.order-summary-products').data('uuid')
    state = $(this).val();
    $.ajax
      url: "/transactions/#{uuid}/change_state_shipping_form.js"
      type: "GET",
      data:
        state: state

onShowHideBillingAddress = ->
  $('.desktop-payment-form input[name=address_type]').click ->
    address_type = $('input[name=address_type]:checked').val()
    if address_type == 'shipping_address'
      if $("#must-have-different-biiling-address").length
        $('#address_type_billing_address').prop("checked", true)
        $("#must-have-different-biiling-address").show()
      else
        $('.desktop-payment-form #will_create_billing_address').val(false)
        $('.desktop-payment-form .billing-address-info').slideUp()
        $('.desktop-payment-form .billing-address-info .billing-address').prop('disabled', true)
    else
      $('.desktop-payment-form #will_create_billing_address').val(true)
      $('.desktop-payment-form .billing-address-info').slideDown()
      $('.desktop-payment-form .billing-address-info .billing-address').prop('disabled', false)

onFillColorToShippingInput = ->
  inputs = [
    '.shipping-address-first-name',
    '.shipping-address-last-name',
    '.shipping-address-street1',
    '.shipping-address-city',
    '.shipping-address-postal-code',
    '.shipping-address-phone',
    '.shipping-address-company',
    '.shipping-address-apartment',
    '.shipping-address-email',
    '.billing-address'
  ]
  _.map(inputs, (i) ->
    _.map($(i), ($i) ->
      if $($i).val() != ""
        $($i).animate({backgroundColor:'#e8f0fe'}, 500);
        $($i).parent().find('.fa-check').css("display", 'inline-block');
    )
  )

addRuleToOptionalFields = ->
  _.map($('.transaction-address-req-field'), (i) ->
    $(i).rules('add', {
      required: true
    });
  )

handleSubmitForm = ->
  $(".checkout-section").on "click", ".btn-submit", (e) ->
    e.preventDefault();
    if $(this).parents("form").valid()
      $(this).parents("form").submit();

window.ValidateForm =
  run: ->
    $(document).ready ->
      validateShippingAddressForm()
      validateMobileShippingAddressForm()
      onInputRequiredShippingFormField()
      onInputUnrequiredShippingFormField()
      onChangeState()
      onFillColorToShippingInput()
      handleSubmitForm()
      onShowHideBillingAddress()
      validateBillingAddressForm()

      addRuleToOptionalFields()