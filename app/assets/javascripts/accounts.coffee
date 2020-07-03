onClickEditPassword = ->
  $(".edit-password").click ->
    if $(this).hasClass('will-close')
      $(this).html('Edit')
      $('.update-password').hide()
      $('.new-passwod').slideUp('slow')
      $(this).removeClass('will-close')

      $('.alert-error').slideUp("slow")
      $(this).parents('.items-group').find(".input-will-show").hide()
      $(this).parents('.items-group').find(".label-will-hide").show()
    else
      $(this).html('Cancel')
      $('.update-password').show()
      $('.new-passwod').slideDown('slow')
      $(this).addClass('will-close')
      $(this).parents('.items-group').find(".input-will-show").show().focus()
      $(this).parents('.items-group').find(".label-will-hide").hide()

onInputPassword = ->
  $('#current_password, #new_password, #password_confirmation').keypress ->
    $(this).parent().find('.alert-error').slideUp("slow").html('')

valid_password_fields = ->
  if $('#current_password').val().trim() == ""
    $('#current_password').parent().find('.alert-error').html('This field is required').css("display", "inline-block")
  if $('#new_password').val().trim() == ""
    $('#new_password').parent().find('.alert-error').html('This field is required').css("display", "inline-block")
  if $('#password_confirmation').val().trim() == ""
    $('#password_confirmation').parent().find('.alert-error').html('This field is required').css("display", "inline-block")

  if ($('#new_password').val().trim() != $('#password_confirmation').val())
    $('#password_confirmation').parent().find('.alert-error').html("Password doesn't match").css("display", "inline-block")

  if($('#current_password').val().trim() != "" && $('#new_password').val().trim() != "" && $('#password_confirmation').val().trim() != "") && ($('#new_password').val().trim() == $('#password_confirmation').val().trim())
    true
  else
    false

onClickUpdatePassword = ->
  $(".update-password").click ->
    password = $('#current_password').val()
    new_password = $('#new_password').val()
    _this = this
    if valid_password_fields()
      $.ajax
        method: "PUT"
        url: '/people'
        dataType : 'json',
        data:
          person: {password: password}
          new_password: new_password
        success: (response) ->
          if response.success
            swal("Successfully!", "Update information successfully", "success", {
              buttons: false,
              timer: 2000,
            });
            handleAnimationWhenDataChanges(_this)
          else
            swal("Failure!", response.message, "error");


valid_email_fields = ->
  if $('#address').val().trim() == ""
    $('#address').parent().find('.alert-error').html('This field is required').css("display", "inline-block")
    false
  else
    true

onClickUpdateEmail = ->
  $(".update-email").click ->
    # email is address attr in email table
    _this = this
    email = $("#address").val()
    id = $("#address_id").val()
    if valid_email_fields()
      $.ajax
        method: "PUT"
        url: '/people'
        dataType : 'json',
        data:
          email: {id: id, address: email}
        success: (response) ->
          if response.success
            swal("Successfully!", "Update information successfully", "success", {
              buttons: false,
              timer: 2000,
            });
            handleAnimationWhenDataChanges(_this)
            $('.label-user-email').html(response.email)
          else
            swal("Failure!", response.message, "error");

valid_name_fields = ->
  if $('#first_name').val().trim() == "" || $('#first_name').val().trim() == ""
    $('#first_name').parent().find('.alert-error').html('At least one field must be filled').css("display", "inline-block")
    false
  else
    true

onClickUpdateName = ->
  $(".update-name").click ->
    _this = this
    last_name = $("#last_name").val()
    first_name = $("#first_name").val()
    if valid_name_fields()
      $.ajax
        method: "PUT"
        url: '/people'
        dataType : 'json',
        data:
          person: {given_name: last_name, family_name: first_name}
        success: (response) ->
          if response.success
            swal("Successfully!", "Update information successfully", "success", {
              buttons: false,
              timer: 2000,
            });
            handleAnimationWhenDataChanges(_this)
            $('.label-user-name').html(response.fullname)
          else
            swal("Failure!", response.message, "error");

handleAnimationWhenDataChanges = (element) ->
  this_item = $(element).parents('.items-group').find('.edit-item')
  if this_item.hasClass('will-close')
    this_item.html('Edit')
    this_item.removeClass('will-close')
    this_item.parent().find('.update-item').hide()
    $('.alert-error').slideUp("slow")
    this_item.parents('.items-group').find(".label-will-hide").show()
    this_item.parents('.items-group').find(".input-will-show").hide()
  else
    this_item.html('Cancel')
    this_item.addClass('will-close')
    this_item.parent().find('.update-item').show()
    this_item.parents('.items-group').find(".label-will-hide").hide()
    this_item.parents('.items-group').find(".input-will-show").show().focus()

onClickEditItems = ->
  $(".edit-item").click ->
    handleAnimationWhenDataChanges(this)

onClickSetDefaultAddress = ->
  $('.set-as-default-address').click ->
    _this = this
    _this_checkbox = $(this).find('input[name=default_shipping_address]')
    id = $(this).data("transaction-address-id")
    $.ajax
      method: "PUT"
      url: "/transaction_addresses/#{id}/set_default_address"
      dataType : 'json'
      success: (response) ->
        if response.success
          $('input[name=default_shipping_address]').not(_this_checkbox).prop('checked', false)
          $(".is-defaut-address").hide()
          $(".set-as-default-address").show()
          $(_this).parent().find(".is-defaut-address").show()
          $(_this).hide()
        else

window.Accounts =
  run: ->
    $(document).ready ->
      onClickEditPassword()
      onClickUpdatePassword()
      onInputPassword()
      onClickEditItems()
      onClickUpdateEmail()
      onClickUpdateName()
      onClickSetDefaultAddress()