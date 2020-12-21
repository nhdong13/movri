window.Commons =
  formatEmail: ->
    EMAIL_FORMAT = /^([a-zA-Z0-9+_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/
    jQuery.validator.addMethod 'emailFormat', ((value, element) ->
      @optional(element) or EMAIL_FORMAT.test(value)
    ), "Invalid email"

  formatPhone: ->
    $(".phone-input").keyup (e) ->
      val_old = $(this).val();
      val = val_old.replace(/\D/g, '');
      len = val.length;
      if (len >= 1)
        val = '(' + val.substring(0);
      if (len >= 3)
        val = val.substring(0, 4) + ') ' + val.substring(4);
      if (len >= 6)
        val = val.substring(0, 9) + '-' + val.substring(9);
        $(this).attr('maxlength', '14');
      if (val != val_old)
        $(this).focus().val('').val(val);

  formatPostalCode: ->
    $('.postal-code').keyup (e) ->
      val = $(this).val().replace(/\s/g, '');
      if (val.length > 0 && val.length >= 3)
        new_val = val.substr(0, 3) + " " + val.substr(3);
        $(this).val(new_val);

  CanadianZipCodeRule: ->
    jQuery.validator.addMethod 'cdnPostal', ((value, element) ->
      return this.optional(element) ||
      value.match(/^[ABCEGHJ-NPRSTVXY]\d[ABCEGHJ-NPRSTV-Z][ -]?\d[ABCEGHJ-NPRSTV-Z]\d$/i);
    ), "Please specify a valid Canadian postal code."

  formatCardName: ->
    $('#card_name').keyup ->
      $(this).val($(this).val().toUpperCase())

  handleArrowUpDownListing: ->
    liSelected = undefined
    input = $('.searchbox-algolia input')
    $(window).keydown (e) ->
      li = $('.search-result-algolia li')
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

  handleToggleCategories: ->
    $('.toggle-cat').click ->
      subcategories = $(this).parents('.menu-categories').find(".subcategories");
      icon = $(this).parents(".main-category").find("i")
      if subcategories.is(":visible")
        subcategories.slideUp("slow");
        icon.removeClass("icon-chevron-up").addClass("icon-chevron-down")
      else
        subcategories.slideDown("slow");
        icon.removeClass("icon-chevron-down").addClass("icon-chevron-up")

  handleToggleChildCategories: ->
    $('.toggle-subcategory').click (e) ->
      icon = $(this).parents('.subcategory').find("i")
      childcategories = $(this).parents('.subcategory').find(".child-categories");
      if childcategories.is(":visible")
        childcategories.slideUp("slow");
        icon.removeClass("icon-chevron-up").addClass("icon-chevron-down")
      else
        childcategories.slideDown("slow");
        icon.removeClass("icon-chevron-down").addClass("icon-chevron-up")

  handleToggleMenuCategory: ->
    $('.mobile-menu-icon, #close-mobile-menu').click (e) ->
      if($('#mobile-menu').is(":visible"))
        $('#mobile-menu').hide()
      else
        $('#mobile-menu').show()

  onClickAddToWishList: ->
    $('.wish-list-btn').click (e) ->
      id = $(this).data("id")
      $.ajax
        method: "GET"
        url: '/wish_lists/add_to_wish_list.js'
        data:
          id: id

  onClickIconSearchBar: ->
    $(".header-search-icon").click ->
      $('.view-all-products a')[0].click()

$(document).ready ->
  Commons.formatPhone()
  Commons.CanadianZipCodeRule()
  Commons.formatEmail()
  Commons.formatCardName()
  Commons.handleArrowUpDownListing()
  Commons.handleToggleCategories()
  Commons.handleToggleChildCategories()
  Commons.handleToggleMenuCategory()
  Commons.onClickAddToWishList()
  Commons.onClickIconSearchBar()
  Commons.formatPostalCode()