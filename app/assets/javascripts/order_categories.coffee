onClickMoveUpCategory = ->
  $('.category-action-up').click ->
    row = $(this).parents('.top-level-category-container')
    row_prev = row.prev()
    $(row).insertAfter(row_prev);

onClickMoveDownCategory = ->
  $('.category-action-down').click ->
    row = $(this).parents('.top-level-category-container')
    row_next = row.next()
    $(row).insertAfter(row_next);

window.OrderCategories =
  run: ->
    $(document).ready ->
      onClickMoveUpCategory()
      onClickMoveDownCategory()
