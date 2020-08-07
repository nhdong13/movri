onClickSelectImageSpan = ->
  $('#custome-image .upload-image-btn, #image').click ->
    $('#custome-image #checkout_setting_logo').trigger('click')

readURL = (input) ->
  if input.files and input.files[0]
    reader = new FileReader

    reader.onload = (e) ->
      $('#image img').attr 'src', e.target.result

    reader.readAsDataURL input.files[0]

previewImage = ->
  $('#checkout_setting_logo').change ->
    readURL this

onCheckAbandonedCheckouts = ->
  $('#checkout_setting_auto_send_abandoned_mails').click ->
    if $(this).is(':checked')
      $("input[name='checkout_setting[abandoned_emails_will_send_to_option]']").prop('disabled', true)
      $("input[name='checkout_setting[time_abandoned_emails_will_send_option]']").prop('disabled', true)
      $('.abandoned-box').addClass('el-disabled')
    else
      $("input[name='checkout_setting[abandoned_emails_will_send_to_option]']").prop('disabled', false)
      $("input[name='checkout_setting[time_abandoned_emails_will_send_option]']").prop('disabled', false)
      $('.abandoned-box').removeClass('el-disabled')

window.CheckoutSetting =
  run: ->
    $(document).ready ->
      onClickSelectImageSpan()
      previewImage()
      onCheckAbandonedCheckouts()