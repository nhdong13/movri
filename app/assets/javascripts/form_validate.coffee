validateShippingAddressForm = ->
  $(".desktop-shipping-address").validate
    rules:
      'shipping_address[first_name]':
        required: true
        minlength: 2
      'shipping_address[last_name]':
        required: true
        minlength: 2
      'shipping_address[street1]':
        required: true
      'shipping_address[city]':
        required: true
      'shipping_address[postal_code]':
        required: true
        minlength: 6
        cdnPostal: true
      'shipping_address[phone]':
        required: true

validateMobileShippingAddressForm = ->
  $(".mobile-shipping-address").validate
    rules:
      'shipping_address[first_name]':
        required: true
        minlength: 2
      'shipping_address[last_name]':
        required: true
        minlength: 2
      'shipping_address[street1]':
        required: true
      'shipping_address[city]':
        required: true
      'shipping_address[postal_code]':
        required: true
        minlength: 6
        cdnPostal: true
      'shipping_address[phone]':
        required: true

onInputRequiredShippingFormField = ->
  $('#shipping_address_first_name,
    #shipping_address_last_name,
    #shipping_address_street1,
    #shipping_address_city,
    #shipping_address_postal_code,
    #shipping_address_phone').change ->
    if $(this).valid()
      $(this).animate({backgroundColor:'#e8f0fe'}, 500);
      $(this).parent().find('.fa-check').css("display", 'inline-block');
    else
      $(this).parent().find('.fa-check').hide();
      $(this).animate({backgroundColor:'white'}, 500);

onInputUnrequiredShippingFormField = ->
  $('#shipping_address_company, #shipping_address_apartment, #email').change ->
    if $(this).val() != ""
      $(this).animate({backgroundColor:'#e8f0fe'}, 500);
      $(this).parent().find('.fa-check').css("display", 'inline-block');
    else
      $(this).parent().find('.fa-check').hide();
      $(this).animate({backgroundColor:'white'}, 500);

onChangeState = ->
  $('.shipping-address-state').change ->
    state = $(this).val();
    $.ajax
      url: '/shipping_addresses/change_state_shipping_form.js'
      type: "GET",
      data:
        state: state

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
    '.shipping-address-email'
  ]
  _.map(inputs, (i) ->
    _.map($(i), ($i) ->
      if $($i).val() != ""
        $($i).animate({backgroundColor:'#e8f0fe'}, 500);
        $($i).parent().find('.fa-check').css("display", 'inline-block');
    )
  )

handleSubmitForm = ->
  $("body").on "click", ".btn-submit", (e) ->
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