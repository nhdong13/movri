window.ST = window.ST || {};

(function(module) {
  module.initPricingChart = function() {
    showPricingChart();
    closePricingChart();
    showMobilePricingChart();
    closeMobilePricingChart();
  };

  function showPricingChart() {
    $(".show-pricing-chart-modal").on('click', function() {
      $("#pricing-chart-modal").css('display', "block");
    })
  };

  function closePricingChart () {
    $('#pricing-chart-modal .close').on('click', function() {
      $("#pricing-chart-modal").css('display', "none");
    });
  }

  function showMobilePricingChart() {
    $(".mobile-show-pricing-chart-modal").on('click', function() {
      $("#mobile-pricing-chart-modal").css('display', "block");
    })
  };

  function closeMobilePricingChart () {
    $('#mobile-pricing-chart-modal .mobile-close').on('click', function() {
      $("#mobile-pricing-chart-modal").css('display', "none");
    });
  }

})(window.ST);
