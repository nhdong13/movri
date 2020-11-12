onClickRemoveIcon = ->
  $('body').on 'click', '.wish-list-remove-icon', ->
    id = $(this).data("id")
    $.ajax
      method: "GET"
      url: '/wish_lists/remove_out_of_wish_list.js'
      data:
        id: id

onClickAddWishListItemToCart = ->
  $('body').on 'click', '.add-wish-list-to-cart', ->
    id = $(this).data("id")
    $.ajax
      method: "GET"
      url: '/wish_lists/add_wish_list_item_to_cart.js'
      data:
        id: id

window.WishList =
  run: ->
    $(document).ready ->
      onClickRemoveIcon()
      onClickAddWishListItemToCart()