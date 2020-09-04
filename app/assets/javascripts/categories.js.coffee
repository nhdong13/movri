window.ST = window.ST or {}
((module) ->
  onOpenCategoriesFilter = ->
    $('.sort-filter-bar #filter').click ->
      $('.mobile-listing-filter').show()

  onQuickCategoriesFilter = ->
    $('.quick-filter-btn, .quick-filter-icon').click ->
      $('.mobile-listing-filter').hide()

  module.HandleMobilePagination = ->
    onQuickCategoriesFilter()
    onOpenCategoriesFilter()

) window.ST
