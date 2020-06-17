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
    promoCode = $(this).parents('.shipping-promo-code').find("input[name=promo_code]").val()
    uuid = $(this).parents(".shipping-promo-code").data('uuid')
    $.ajax
      method: "GET"
      url: "/transactions/#{uuid}/update_promo_code.js"
      data:
        promo_code: promoCode

window.Shipment =
  run: ->
    $(document).ready ->
      onClickShipmentItems()
      onChangePromoCode()