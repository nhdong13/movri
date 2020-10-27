onClickUpQuantity = ->
  $('#quantity-up, #quantity-up-mobile').click ->
    currentVal = parseInt($('input#quantity-number').val()) || 0
    new_val = currentVal + 1
    $("input#quantity-number").val(new_val)
    $("input#quantity-number-mobile").val(new_val)
    update_price_listing(new_val)


onClickDownQuantity = ->
  $('#quantity-down, #quantity-down-mobile').click ->
    currentVal = parseInt($('input#quantity-number').val()) || 1
    if(currentVal != 0)
      new_val = currentVal - 1
    else
      new_val = 0
    $('input#quantity-number').val(new_val)
    $("input#quantity-number-mobile").val(new_val)
    update_price_listing(new_val)

update_price_listing = (quantity) ->
  listing_id = $('#listing_id').val()
  $.ajax
    method: "GET"
    url: "/listings/#{listing_id}/get_price_base_on_duration"
    data:
      quantity: quantity
    success: (response) ->
      $('.main-listing-price').text(response.price)

window.ListingDetails =
  run: ->
    $(document).ready ->
      onClickUpQuantity()
      onClickDownQuantity()