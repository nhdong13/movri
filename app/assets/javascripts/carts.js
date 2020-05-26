window.ST = window.ST || {};

(function(module) {
  function throttle(func, milliseconds) {
    var lastCall = 0;
    return function () {
      var now = Date.now();
      if (lastCall + milliseconds < now) {
        lastCall = now;
        return func.apply(this, arguments);
      }
    };
  }

  module.initCart = function() {
    onChangeQuantity();
  };

  function onChangeQuantity () {
    $('#quantity').on('change', function() {
      var quantity = $(this).val();
      if(quantity < 1){
        $(this).val(1)
      }
      parent = $(this).parents(".listing-info")
      price_item = parent.find("#readable_price").val()
      total_price_item = price_item * quantity
      parent.find('#price-item').html(total_price_item)
    });
  }

  $(".remove-item-in-cart-detail").on("click", function () {
    var listingId = $(this).attr('id').split("-").pop();
    var elementId = "#listing-info-" + listingId;
    var removeItemInCartUrl = "/en/listings/" + listingId + "/remove_cart_item";

    $.ajax({
      url: removeItemInCartUrl,
      type: "GET"
    }).done(function(response) {
      if (response.success === true) {
        location.reload(true);
      } else {
        // TODO:
      }
    }).fail(function(error) {
      console.log("Error:", error);
    });

  });

  $("#cart_deatail_return_date").on("change", throttle(function () {
    var changeBookingDayUrl = "/en/change_booking_days";
    var startDate = $("#cart_deatail_arrival_date").val();
    var endDate = $("#cart_deatail_return_date").val();

    if (!startDate || !endDate) {
      return;
    }

    $.ajax({
      url: changeBookingDayUrl,
      type: "POST",
      data: {
        start_date: startDate,
        end_date: endDate
      }
    }).done(function(response) {
      console.log('response', response);
      if (response.success === true) {
        // Change days booking successful
        location.reload();
      } else {
        // Days not change
      }
    }).fail(function(error) {
      console.log("Error:", error);
    });

  }, 1000));

  $(".mobile-number-item-in-cart-detail, .cart-detail-item-quantity").on("change", function () {
    var id = event.target.id;
    var total = $("#" + id).val();
    var listingId = id.split("-").pop();
    var plusItemUrl = "/en/listings/" + listingId + "/change_number_of_item";

    $.ajax({
      url: plusItemUrl,
      type: "POST",
      data: {
        total: total
      }
    }).done(function(response) {
      if (response.success === true) {
        location.reload(true);
      } else {
        //TODO:
        location.reload(true);
      }
    }).fail(function(error) {
      console.log(error);
    })
  });

})(window.ST);
