onClickShipmentItems = ->
  $('.shipping-select-box .enabled-shipping-select').click ->
    $(this).find("input[type=radio]").prop("checked", true)
    uuid = $(this).parents(".shipping-select-box").data('uuid')
    shipping_type = $(this).find("input[type='radio']").val()
    $.ajax
      method: "GET"
      url: "/transactions/#{uuid}/change_shipping_selection.js"
      data:
        shipping_type: shipping_type

onChangePromoCode = ->
  $(".shipping-promo-code button[type=submit]").click ->
    $('.promo-code-error').hide()
    $('.coupon-code-apply').hide();
    promoCode = $(this).parents('.shipping-promo-code').find("input[name=promo_code]").val()
    uuid = $(this).parents(".shipping-promo-code").data('uuid')
    $.ajax
      method: "GET"
      url: "/transactions/#{uuid}/update_promo_code.js"
      data:
        promo_code: promoCode

onClickSubmitCreateNewCustomer = ->
  $("#create-new-customer-modal input[type=submit]").click (e) ->
    e.preventDefault()
    $(".create-customer-error").hide()
    form_data = new FormData($("#create-new-customer-modal form")[0])
    $.ajax(
      method: "POST"
      url: "/admin/communities/1/people"
      dataType: "JSON"
      data: form_data
      processData: false
      contentType: false).done((response) ->
        if !response.success
          $(".create-customer-error").text(response.message).show()
        else
          $(".close-modal").click()
      ).fail (error) ->
        console.log 'Error:', error

onClickCloseCreateCustomerModel = ->
  $(".close-create-customer").click (e) ->
    e.preventDefault();
    $(".close-modal").click()

window.Shipment =
  run: ->
    $(document).ready ->
      onClickShipmentItems()
      onChangePromoCode()
      onClickSubmitCreateNewCustomer()
      onClickCloseCreateCustomerModel()