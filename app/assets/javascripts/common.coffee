
window.Commons =
  formatEmail: ->
    EMAIL_FORMAT = /^([a-zA-Z0-9+_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/
    jQuery.validator.addMethod 'emailFormat', ((value, element) ->
      @optional(element) or EMAIL_FORMAT.test(value)
    ), "Invalid email"

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
  Commons.formatEmail()
