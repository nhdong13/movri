window.ST = window.ST || {};

(function(module) {
  module.initCalculateShippingRates = function() {
    showShippingRatesRealtimeModal();
    closeShippingRatesModal();
  };

  module.initMobileCalculateShippingRates = function() {
    showMobileShippingRatesRealtimeModal();
    closeMobileShippingRatesModal();
  }

  module.getShippingRates = function(locale, listingId) {
    $(".button-calculate-shipping" ).click(function() {
      $(".button-calculate-shipping").attr("disabled", true);
      $('#shipping-rates-table').empty();
      $(".cannot-calculated").hide();
      $(".loading").show();

      var zipcode = $("#zipcode").val();

      if (!zipcode || /^\s*$/.test(zipcode)) {
        alert("Please enter a valid zipcode!");
      } else {
        $.ajax({
          url: `/${locale}/listings/${listingId}/get_shipping_rates_from_postmen`,
          type: "POST",
          data: {
            zipcode: zipcode
          }
        }).done(function(response) {
          console.log(response);
          $(".loading").hide();
          var hashResponse = JSON.parse(response.data.rates);
          var rates = hashResponse.data.rates;

          if(rates && hashResponse.meta.code === 200) {
            $('#shipping-rates-table').empty();

            for (var i = 0; i < rates.length; i++ ) {
              $('#shipping-rates-table').append(`
                <tr>
                  <td>${hashResponse.data.rates[i].service_name}</td>
                  <td align="right">
                    $${hashResponse.data.rates[i].total_charge.amount} shipping (${hashResponse.data.rates[i].total_charge.currency})
                  </td>
                </tr>
              `);
            }
          } else {
            $(".cannot-calculated").show();
          }

          $(".button-calculate-shipping").attr("disabled", false);
        }).fail(function(error) {
          $(".cannot-calculated").show();
          $(".loading").hide();
          $(".button-calculate-shipping").attr("disabled", false);
        })
      }
    });
  };

  module.getMobileShippingRates = function(locale, listingId) {
    $(".mobile-button-calculate-shipping" ).click(function() {
      $(".mobile-button-calculate-shipping").attr("disabled", true);
      $('#mobile-shipping-rates-table').empty();
      $(".mobile-cannot-calculated").hide();
      $(".mobile-loading").show();

      var zipcode = $("#mobile-zipcode").val();

      if (!zipcode || /^\s*$/.test(zipcode)) {
        alert("Please enter a valid zipcode!");
      } else {
        $.ajax({
          url: `/${locale}/listings/${listingId}/get_shipping_rates_from_postmen`,
          type: "POST",
          data: {
            zipcode: zipcode
          }
        }).done(function(response) {
          console.log(response);
          $(".mobile-loading").hide();
          var hashResponse = JSON.parse(response.data.rates);
          var rates = hashResponse.data.rates;

          if(rates && hashResponse.meta.code === 200) {
            $('#mobile-shipping-rates-table').empty();

            for (var i = 0; i < rates.length; i++ ) {
              $('#mobile-shipping-rates-table').append(`
                <tr>
                  <td>${hashResponse.data.rates[i].service_name}</td>
                  <td align="right">
                    $${hashResponse.data.rates[i].total_charge.amount} shipping (${hashResponse.data.rates[i].total_charge.currency})
                  </td>
                </tr>
              `);
            }
          } else {
            $(".cannot-calculated").show();
          }

          $(".mobile-button-calculate-shipping").attr("disabled", false);
        }).fail(function(error) {
          $(".mobile-cannot-calculated").show();
          $(".mobile-loading").hide();
          $(".mobile-button-calculate-shipping").attr("disabled", false);
        })
      }
    });
  };

  function showShippingRatesRealtimeModal() {
    $(".show-shipping-rates-modal").on('click', function() {
      $("#shipping-rates-realtime-modal").css('display', "block")
    })
  };

  function showMobileShippingRatesRealtimeModal() {
    $(".mobile-show-shipping-rates-modal").on('click', function() {
      console.log('clicked')
      $("#mobile-shipping-rates-realtime-modal").css('display', "block");
    })
  }

  function closeShippingRatesModal () {
    $('#shipping-rates-realtime-modal .close').on('click', function() {
      $("#shipping-rates-realtime-modal").css('display', 'none');
    });
  }

  function closeMobileShippingRatesModal () {
    $('#mobile-shipping-rates-realtime-modal .mobile-close').on('click', function() {
      $("#mobile-shipping-rates-realtime-modal").css('display', 'none');
    });
  }
})(window.ST);
