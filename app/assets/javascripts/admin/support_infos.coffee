onClickChangeImage = ->
  $(".change-support-image-btn").click ->
    $('#support_info_image').trigger('click')

readURL = (input) ->
  if input.files and input.files[0]
    reader = new FileReader

    reader.onload = (e) ->
      $('.preview img').attr 'src', e.target.result

    reader.readAsDataURL input.files[0]

previewImage = ->
  $('#support_info_image').change ->
    readURL this

window.SupportInfo =
  run: ->
    $(document).ready ->
      onClickChangeImage()
      previewImage()