validateShippingAddressForm = ->
  $("#new_shipping_address").validate
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
        minlength: 4
        number: true
      'shipping_address[phone]':
        required: true
        minlength: 10
        number: true

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
  $('#shipping_address_state_or_province').change ->
    state = $(this).val();
    $.ajax
      url: '/shipping_addresses/change_state_shipping_form.js'
      type: "GET",
      data:
        state: state

window.ValidateForm =
  run: ->
    $(document).ready ->
      validateShippingAddressForm()
      onInputRequiredShippingFormField()
      onInputUnrequiredShippingFormField()
      onChangeState()