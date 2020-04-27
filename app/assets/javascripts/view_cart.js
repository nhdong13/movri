window.ST = window.ST || {};

(function(module) {
  module.initViewCart = function() {
    showViewCart();
    closeViewCart();
    showMobileViewCart();
    closeMobileViewCart();
  };

  function showViewCart() {
    $(".show-view-cart-modal").on('click', function() {
      $("#view-cart-modal").css('display', "block");
    })
  };

  function closeViewCart () {
    $('#view-cart-modal .close').on('click', function() {
      $("#view-cart-modal").css('display', "none");
    });
  }


  function showMobileViewCart() {
    $(".mobile-show-view-cart-modal").on('click', function() {
      $("#mobile-view-cart-modal").css('display', "block");
    })
  };

  function closeMobileViewCart () {
    $('#mobile-view-cart-modal .mobile-close').on('click', function() {
      $("#mobile-view-cart-modal").css('display', "none");
    });
  }

})(window.ST);
