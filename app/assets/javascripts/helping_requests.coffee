validateHelpingRequestForm = ->
  $("#new_helping_request").validate
    rules:
      'helping_request[email]':
        required: true
        emailFormat: true
      'helping_request[subject]':
        required: true
      'helping_request[message]':
        required: true

onClickContactUs = ->
  $(".contact-us-link").click ->
    $('.helping-request-partial').slideDown('slow')
    $('.helping-request-partial #helping_request_subject').focus()
    $([document.documentElement, document.body]).animate({
      scrollTop: $("#helping_request_subject").offset().top
    }, 1000);

onCLickCloseContactUsPartial = ->
  $('.close-contact-us-partial').click ->
    $('.helping-request-partial').slideUp('slow')
    $([document.documentElement, document.body]).animate({
      scrollTop: $(".payment-section").offset().top
    }, 1000);

window.HelpingRequest =
  run: ->
    $(document).ready ->
      validateHelpingRequestForm()
      onClickContactUs()
      onCLickCloseContactUsPartial()