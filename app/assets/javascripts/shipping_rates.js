window.ST = window.ST || {};

(function(module) {
  module.initCalculateShippingRates = function() {
    showShippingRatesRealtimeModal();
    closeShippingRatesModal()
  };

  module.getShippingRates = function(locale, listingId) {
    $(".button-calculate-shipping" ).click(function() {
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
        }).done(function( msg ) {

        });
      }
    });
  };

  function showShippingRatesRealtimeModal() {
    $(".show-shipping-rates-modal").on('click', function() {
      $("#shipping-rates-realtime-modal").css('display', "block")
    })
  };

  function closeShippingRatesModal () {
    $('#shipping-rates-realtime-modal .close').on('click', function() {
      $("#shipping-rates-realtime-modal").css('display', 'none');
    });
  }
})(window.ST);
