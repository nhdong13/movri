window.ST = window.ST || {};

(function(module) {
  module.initCalculateShippingRates = function() {
    showShippingRatesRealtimeModal();
    closeShippingRatesModal()
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
