window.ST = window.ST or {}
((module) ->
  onClickPreviousBtn = ->
    $('.previous-btn, .next-btn').click (e) ->
      e.preventDefault()
      form = $(this).parents("form")
      $page = form.find('#page')
      page = parseInt($(this).data('page'))
      if page
        $page.val(page)
        form.submit()

  onChangeSelectPage = ->
    $(".page-select-box select").change ->
      form = $(this).parents("form")
      $page = form.find('#page')
      page = parseInt($(this).val())
      $page.val(page)
      form.submit()

  onSortListing = ->
    $("#sort_listing").change ->
      data = $(this).val()
      $.ajax
        method: "GET"
        url: '/categories'
        dataType : 'json',
        data:
          sort_condition: data
        success: (response) ->
          window.location = response.redirect_url;

  module.HandleMobilePagination = ->
    onClickPreviousBtn()
    onChangeSelectPage()
    onSortListing()

) window.ST
