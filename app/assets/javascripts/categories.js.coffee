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

  module.HandleMobilePagination = ->
    onClickPreviousBtn()
    onChangeSelectPage()

) window.ST
