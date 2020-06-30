window.ST = window.ST || {};
(function(module) {
  var style = {
    base: {
      color: '#32325d',
      lineHeight: '24px',
      fontFamily: '"Helvetica Neue", Helvetica, sans-serif',
      fontSmoothing: 'antialiased',
      fontSize: '16px',
      '::placeholder': {
        color: '#aab7c4'
      }
    },
    invalid: {
      color: '#fa755a',
      iconColor: '#fa755a'
    }
  };
  var stripe, spinner;

  var createCard = function() {
    var elements = stripe.elements();
    var card = addElementCard(elements)
    return card;
  };

  var addElementCard = function(elements) {
    var cardNumberElement = elements.create('cardNumber', {placeholder: 'Card Number'});
    cardNumberElement.mount('#card-number');
    var cardExpiryElement = elements.create('cardExpiry', {placeholder: 'Expiration date (MM/YY)'});
    cardExpiryElement.mount('#card-expiry');
    var cardCvcElement = elements.create('cardCvc', {placeholder: 'Security code'});
    cardCvcElement.mount('#card-cvc');

    cardNumberElement.on('change', function(event) {setOutcome(event);});
    cardExpiryElement.on('change', function(event) {setOutcome(event);});
    cardCvcElement.on('change', function(event) {setOutcome(event);});

    return cardNumberElement;
  }

  function setOutcome(result) {
    var displayError = $('.stripe-errors')
    if(result.error) {
      displayError.css('display', 'block')
      displayError.html(result.error.message);
      $('#valid_payment_card').val(false)
    } else {
      $('#valid_payment_card').val(true)
      displayError.slideUp('slow')
      displayError.html('')
    }
  }

  var validateForm = function(form) {
    if(!form.valid()) {
      return false;
    }
    return true;
  };

  var initCharge = function(options){
    stripe = Stripe(options.publishable_key);

    $("#shipping_address_country_code").change(function(){
      if($(this).val() == 'US') $(".us-only").show(); else $(".us-only").hide();
    });
    $("#shipping_address_country_code").trigger("change");

    var card = createCard();

    $("#send-add-card").on('click', function(event) {
      event.preventDefault();
      var form = $("#transaction-form");
      if (!validateForm(form)) {
        return false;
      }

      stripe.createToken(card).then(function(result) {
        var errorElement = document.getElementById('card-errors');
        if (result.error) {
          errorElement.textContent = result.error.message;
          errorElement.className = 'error';
        } else {
          errorElement.className = 'hidden';
          var input = $("<input/>", {type: "hidden", name: "stripe_token", value: result.token.id});
          form.append(input);
          $("#payment_type").val("stripe");
          if(form.valid()) {
            form.submit();
          }
        }
      });
    });
  };

  var handleCreatedPaymentIntent = function(response) {
    var payment = response.stripe_payment_intent;
    if (payment.error) {
      showError(ST.t('error_messages.stripe.generic_error'));
    } else if (payment.requires_action) {
      stripe.handleCardAction(
        payment.client_secret
      ).then(function(result) {
        if (result.error) {
          showError(ST.t('error_messages.stripe.generic_error'));
          $.post(
            payment.failed_intent_path,
            {
              stripe_payment_id: payment.stripe_payment_id,
            },
            function(data) {
              if (!data.success) {
                showError(data.error);
              }
            },
            'json'
          );
        } else {
          // The card action has been handled
          // The PaymentIntent can be confirmed again on the server
          $.post(
            payment.confirm_intent_path,
            {
              stripe_payment_id: payment.stripe_payment_id,
              payment_intent_id: result.paymentIntent.id
            },
            function(data) {
              if (data.success) {
                window.location = data.redirect_url;
              } else {
                showError(data.error);
              }
            },
            'json'
          );
        }
      });
    } else {
      // Show success message
    }
  };

  var showError = function(message) {
    ST.utils.showError(message, 'error');
    ST.transaction.toggleSpinner(spinner, false);
    $('html, body').animate({ scrollTop: $('.flash-notifications').offset().top}, 1000);
  };

  var formSubmit = function(e) {
    var form = $(this),
      formAction = form.attr('action');

    var submitSuccess = function(data, responseStatus) {
      ST.transaction.submitAnimation(false);
      if (data.redirect_url) {
       swal("Successfully!", "Payment Successful!", "success", {
          buttons: false,
          timer: 2000,
        });
        // window.location = data.redirect_url;
        return;
      } else if (data.errors) {
        swal("Failure!", data.errors, "error");
        // showError(data.error);
      }
    };
    $.post(formAction, form.serialize(), submitSuccess, 'json');
  };

  var isCreatingBillingAddress = function() {
    address_type = $('.desktop-payment-form input[name=address_type]:checked').val()
    if(address_type == "billing_address"){
      return true;
    } else {
      return false;
    }
  }
  var initIntent = function(options){
    stripe = Stripe(options.publishable_key);
    var card = createCard();
    var form = $(".desktop-payment-form");

    card.on('ready', function(){card.focus();});
    form.on('stripe-submit', formSubmit);
    $("#send-add-card").on('click', function(event) {
      event.preventDefault();
      if(isCreatingBillingAddress()){
        if (!validateForm(form)) {
          return false;
        }
      }
      ST.transaction.submitAnimation(true);
      stripe.createPaymentMethod('card', card, {}).then(function(result) {
        if (result.error) {
          ST.transaction.submitAnimation(false);
          card.focus()
          showError(ST.t('error_messages.stripe.generic_error'));
        } else {
          // Otherwise send paymentMethod.id to server
          var existingInput = $('#stripe_payment_method_id');
          if (existingInput.length > 0) {
            existingInput.val(result.paymentMethod.id);
          } else {
            var input = $('<input/>', {type: 'hidden', name: 'stripe_payment_method_id', id: 'stripe_payment_method_id', value: result.paymentMethod.id});
            form.append(input);
          }
          if(isCreatingBillingAddress()){
            if(form.valid()) {
              form.trigger('stripe-submit');
            }
          } else {
            form.trigger('stripe-submit');
          }
        }
      });
    });
  };

  module.StripePayment = {
    initCharge: initCharge,
    initIntent: initIntent,
  };
})(window.ST);
