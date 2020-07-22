window.Commons =
  formatEmail: ->
    EMAIL_FORMAT = /^([a-zA-Z0-9+_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/
    jQuery.validator.addMethod 'emailFormat', ((value, element) ->
      @optional(element) or EMAIL_FORMAT.test(value)
    ), "Invalid email"

  formatPhone: ->
    $phoneInput = $('.phone-input ')
    $phoneInput.inputmask({mask: "9 (999) 999-9999", placeholder: ""});

  CanadianZipCodeRule: ->
    jQuery.validator.addMethod 'cdnPostal', ((value, element) ->
      return this.optional(element) ||
      value.match(/^(?!.*[DFIOQU])[A-VXY][0-9][A-Z]●?[0-9][A-Z][0-9]$/);
    ), "Please specify a valid Canadian postal code."

  formatCardName: ->
    $('#card_name').keyup ->
      $(this).val($(this).val().toUpperCase())

  handleArrowUpDownListing: ->
    liSelected = undefined
    input = $('.searchbox-algolia input')
    $(window).keydown (e) ->
      li = $('#search-result li')
      if e.which == 40
        if liSelected
          liSelected.removeClass 'selected'
          next = li.eq(li.index($(liSelected) ) + 1)
          if next.length > 0
            liSelected = next.addClass('selected')
          else
            liSelected = li.eq(0).addClass('selected')
        else
          liSelected = li.eq(0).addClass('selected')
        input.val(liSelected.text().trim())
        e.preventDefault();
      else if e.which == 38
        if liSelected
          liSelected.removeClass 'selected'
          next = li.eq(li.index($(liSelected) ) - 1)
          if next.length > 0
            liSelected = next.addClass('selected')
          else
            liSelected = li.last().addClass('selected')
        else
          liSelected = li.last().addClass('selected')
        input.val(liSelected.text().trim())
        e.preventDefault();
      if e.which == 13
        if liSelected
          href = liSelected.parent('a').attr("href")
          if href
            window.location.href = href

$(document).ready ->
  Commons.formatPhone()
  Commons.CanadianZipCodeRule()
  Commons.formatEmail()
  Commons.formatCardName()
  Commons.handleArrowUpDownListing()
