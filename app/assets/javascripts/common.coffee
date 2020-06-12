window.Commons =
  formatPhone: ->
    $phoneInput = $('.shipping-address-phone')
    $phoneInput.inputmask({mask: "9 (999) 999-9999", placeholder: ""});

$(document).ready ->
  Commons.formatPhone()
