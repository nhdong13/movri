onUpQuantity = ->
  $(".change-quantity .up").click ->
    input_quantity = $(this).parents(".refund-quantity-field").find('.quantity-refund')
    current_quantity = input_quantity.val()
    max_quantity = input_quantity.data("max-quantity")
    next_quantity = parseInt(current_quantity) + 1
    if next_quantity > parseInt(max_quantity)
      input_quantity.val(max_quantity)
    else
      input_quantity.val(next_quantity)
    updateItemsSelected()

updateItemsSelected = ->
  total_items = 0
  _.map($('.quantity-refund'), (i) ->
    total_items += parseInt($(i).val())
  )
  $('.items-selected-number').html(total_items)

onDownQuantity = ->
  $(".change-quantity .down").click ->
    input_quantity = $(this).parents(".refund-quantity-field").find('.quantity-refund')
    current_quantity = input_quantity.val()
    down_quantity = parseInt(current_quantity) - 1
    if down_quantity < 0
      input_quantity.val(0)
    else
      input_quantity.val(down_quantity)
    updateItemsSelected()


onChangeQuantity = ->
  $('.quantity-refund').change ->
    current_quantity = $(this).val()
    max_quantity = $(this).parents(".refund-quantity-field").find('.quantity-refund').data("max-quantity")
    format_quantity = parseInt(current_quantity)
    if Number.isInteger(format_quantity)
      if parseInt(format_quantity) > parseInt(max_quantity)
        $(this).val(max_quantity)
      else if parseInt(format_quantity) < 0
        $(this).val(0)
      else
        $(this).val(format_quantity)
    else
      $(this).val(0)
    updateItemsSelected()

onShowCancelOrder = ->
  $('.cancel-order-btn').click ->
    $('#cancel-order-modal').show()

onCloseCancelOrder = ->
  $('#cancel-order-modal .close, #keep-order-btn').click ->
    $('#cancel-order-modal').hide()

window.RefundSetting =
  run: ->
    $(document).ready ->
      onUpQuantity()
      onDownQuantity()
      onChangeQuantity()
      onShowCancelOrder()
      onCloseCancelOrder()