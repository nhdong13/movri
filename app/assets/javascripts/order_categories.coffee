onClickMoveUpCategory = ->
  $('.category-btn-sort-up').unbind().click (e)  ->
    row = $(this).parents('.top-level-category-container')
    prev_row = row.prev()
    $(row).insertBefore(prev_row);
    updateOrderCategory(row.data("id"), prev_row.data("id"), row, prev_row)

onClickMoveDownCategory = ->
  $('.category-btn-sort-down').unbind().click (e) ->
    row = $(this).parents('.top-level-category-container')
    next_row = row.next()
    $(row).insertAfter(next_row);
    updateOrderCategory(row.data("id"), next_row.data("id"), row, next_row)

onClickMoveUpSubcategory = ->
  $('.subcategory-btn-sort-up').unbind().click (e)  ->
    row = $(this).parents('.sub-categories')
    prev_row = row.prev()
    $(row).insertBefore(prev_row);
    updateOrderCategory(row.data("id"), prev_row.data("id"), row, prev_row)

onClickMoveDownSubcategory = ->
  $('.subcategory-btn-sort-down').unbind().click (e) ->
    row = $(this).parents('.sub-categories')
    next_row = row.next()
    $(row).insertAfter(next_row);
    updateOrderCategory(row.data("id"), next_row.data("id"), row, next_row)

onClickMoveUpChidrencategory = ->
  $('.children-btn-sort-up').unbind().click (e)  ->
    row = $(this).parents('.children-category-row')
    prev_row = row.prev()
    $(row).insertBefore(prev_row);
    updateOrderCategory(row.data("id"), prev_row.data("id"), row, prev_row)

onClickMoveDownChidrencategory = ->
  $('.children-btn-sort-down').unbind().click (e) ->
    row = $(this).parents('.children-category-row')
    next_row = row.next()
    $(row).insertAfter(next_row);
    updateOrderCategory(row.data("id"), next_row.data("id"), row, next_row)

updateOrderCategory = (order1, order2, row1, row2) ->
  if order1 > -1 && order2 > -1
    $.ajax
      type: "POST",
      url: ST.utils.relativeUrl("order"),
      data: { order1: order1, order2: order2 }
      success: (response) ->
        row1.data("id", order2)
        row1.find(".success-icon").show().delay(2000).fadeOut(300);
        row2.data("id", order1)
        row2.find(".success-icon").show().delay(2000).fadeOut(300);
  else
    row2.find(".error-icon").show().delay(2000).fadeOut(300);
    row1.find(".error-icon").show().delay(2000).fadeOut(300);

window.OrderCategories =
  run: ->
    $(document).ready ->
      onClickMoveUpCategory()
      onClickMoveDownCategory()
      onClickMoveUpSubcategory()
      onClickMoveDownSubcategory()
      onClickMoveUpChidrencategory()
      onClickMoveDownChidrencategory()
