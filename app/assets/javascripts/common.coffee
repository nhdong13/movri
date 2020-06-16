window.Commons =
  formatPhone: ->
    $phoneInput = $('.shipping-address-phone')
    $phoneInput.inputmask({mask: "9 (999) 999-9999", placeholder: ""});

  CanadianZipCodeRule: ->
    jQuery.validator.addMethod 'cdnPostal', ((value, element) ->
      return this.optional(element) ||
      value.match(/^(?!.*[DFIOQU])[A-VXY][0-9][A-Z]●?[0-9][A-Z][0-9]$/);
    ), "Please specify a valid Canadian postal code."

$(document).ready ->
  Commons.formatPhone()
  Commons.CanadianZipCodeRule()
