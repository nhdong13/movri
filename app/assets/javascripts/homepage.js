$(function() {
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

  $('.homepage-carousel').on('init', function () {
    $('.loading-carousel').css({display: 'none'});
    $('.homepage-carousel').css({display: 'block', opacity: 1});
  });

  $('.homepage-carousel').slick({
    adaptiveHeigh: true,
    autoplay: true,
    autoplaySpeed: 3000,
    arrows: true,
    dots: true
  });

  // Selectors
  var showFiltersButtonSelector = "#home-toolbar-show-filters";
  var filtersContainerSelector = "#home-toolbar-filters";

  // Elements
  var $showFiltersButton = $(showFiltersButtonSelector);
  var $filtersContainer = $(filtersContainerSelector);

  $showFiltersButton.click(function() {
    $showFiltersButton.toggleClass("selected");
    $filtersContainer.toggleClass("home-toolbar-filters-mobile-hidden");
  });

  // Relocate filters
  if ($("#filters").length && $("#desktop-filters").length) {
    relocate(768, $("#filters"), $("#desktop-filters").get(0));
  }

  if ($("#header-menu-mobile-anchor")[0] && $("#header-menu-desktop-anchor")[0]){
    relocate(768, $("#header-menu-mobile-anchor"), $("#header-menu-desktop-anchor").get(0));
  }

  if ($("#header-menu-mobile-cart")[0] && $("#header-menu-desktop-cart")[0]){
    relocate(768, $("#header-menu-mobile-cart"), $("#header-menu-desktop-cart").get(0));
  }

  relocate(768, $("#header-user-mobile-anchor"), $("#header-user-desktop-anchor").get(0));

  $(".add-item-to-cart").on("click", function() {

    var id = event.target.id;
    var listing_id = id.split("-").pop();
    var addToCartUrl = "/en/listings/" + listing_id + "/add_item_to_cart";
    if($(this).parents('form').valid()){
      $.ajax({
        url: addToCartUrl,
        type: "GET"
      }).done(function(response) {
        if (response.success === true) {
          swal("Successfully!", "1 Item Added to Your Cart!", "success", {
            buttons: false,
            timer: 1000,
          });

          var data = response.data;

          // Change number show on cart
          $(".number-on-cart").html(data.total_items);
          $(".number-item-in-cart").html(data.total_items);

          var divListingId = "#wrap-item-cart-" + data.item;

          if ($(divListingId).length) {
            var quantityNumber = "#quantity-item-" + data.item;
            $(quantityNumber).html(data.item_count);
          } else {
            location.reload();
          }
        } else {
          // TODO:
        }
      }).fail(function(error) {
        swal("Failure!", "Something went wrong!", "error");
        console.log("Error:", error);
      })
    }
  });

  $(".remove-item-in-cart").on("click", function() {
    var id = event.target.id;
    var listing_id = id.split("-").pop();
    var removeItemInCartUrl = "/en/listings/" + listing_id + "/remove_cart_item";

    $.ajax({
      url: removeItemInCartUrl,
      type: "GET"
    }).done(function(response) {
      if (response.success === true) {
        // User in cart detail page
        if (window.location.pathname.includes("show_cart")) {
          location.reload(true);
        }

        var data = response.data;
        var item_id = "#wrap-item-cart-" + data.delete_item;
        // Remove item without reload page
        $(item_id).remove();
        // Change number of item show in header
        $(".number-item-in-cart").html(data.total_items);
        $(".number-on-cart").html(data.total_items);
      } else {
        // TODO:
      }
    }).fail(function(error) {
      console.log("Error:", error);
    })
  });

  $(".plus-item-in-cart").on("click", function() {
    var id = event.target.id;
    var listing_id = id.split("-").pop();
    var plusItemUrl = "/en/listings/" + listing_id + "/plus_item";

    $.ajax({
      url: plusItemUrl,
      type: "GET"
    }).done(function(response) {
      if (response.success === true) {
        // User in cart detail page
        if (window.location.pathname.includes("show_cart")) {
          location.reload(true);
        }

        var data = response.data;

        var item = "#quantity-item-" + data.item;
        $(item).html(data.new_quantity);
        $(".number-item-in-cart").html(data.total_items);
        $(".number-on-cart").html(data.total_items);

        // Change total price after plus item
        var priceId = "#price-item-in-cart" + data.item;
        $(priceId).html(data.value_in_cart);
      } else {
        // TODO:
      }
    }).fail(function(error) {
      console.log("Error:", error);
    })
  });

  $(".minus-item-in-cart").on("click", function() {
    var id = event.target.id;
    var listing_id = id.split("-").pop();
    var plusItemUrl = "/en/listings/" + listing_id + "/minus_item";

    $.ajax({
      url: plusItemUrl,
      type: "GET"
    }).done(function(response) {
      if (response.success === true) {
        // User in cart detail page
        if (window.location.pathname.includes("show_cart")) {
          location.reload(true);
        }

        var data = response.data;

        if (data.delete === true) {
          var item_id = "#wrap-item-cart-" + data.item;
          // Remove item without reload page
          $(item_id).remove();
          // Change number of item show in header
          $(".number-item-in-cart").html(data.total_items);
          $(".number-on-cart").html(data.total_items);
        } else {
          var item = "#quantity-item-" + data.item;
          $(item).html(data.new_quantity);
          $(".number-item-in-cart").html(data.total_items);
          $(".number-on-cart").html(data.total_items);

          // Set total price for this item
          // Total price will change after minus
          var priceId = "#price-item-in-cart" + data.item;
          $(priceId).html(data.value_in_cart);
        }
      } else {
        // TODO:
      }
    }).fail(function(error) {
      console.log("Error:", error);
    })
  });

  $(".cart-icon-header").on("click", function() {
    alert("i");
    var loadCartUrl = "/load_cart";

    $.ajax({
      url: loadCartUrl,
      type: "GET"
    }).done(function(response) {
      if (response.success === true) {
        var data = response.data;
      } else {
        // TODO:
      }
    }).fail(function(error) {
      console.log("Error:", error);
    });
  });

  // User change booking date
  $("#end-on").on("change", throttle(function () {
    var changeBookingDayUrl = "/en/change_booking_days";
    var startDate = $("#start-on").val();
    var endDate = $("#end-on").val();

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

  $("#start-on").on("change", function () {
    var arrivalDate = $("#start-on").val().trim();
    var today = new Date();
    var day = today.getDate();
    var month = today.getMonth() + 1;

    if (month < 10) {
      month = "0" + month;
    }
    if (day < 10) {
      day = "0" + day;
    }

    var date = month + '/' + day + '/' + today.getFullYear();

    if (date == arrivalDate) {
      // swal("Successfully!", "You can pick up from movri office today", "success", {
      // });
    }
  });

  $('.helpful-link-btn').click(function(){
    if($('.more-helpful-links').is(":visible")){
      $('.more-helpful-links').slideUp('slow')
      iconClass = $('.helpful-link-btn').find('.icon-minus')
      iconClass.removeClass("icon-minus").addClass('icon-plus')
    } else {
      $('.more-helpful-links').slideDown('slow')
      iconClass = $('.helpful-link-btn').find('.icon-plus')
      iconClass.removeClass("icon-plus").addClass('icon-minus')
    }
  });

  $('.helpful-link-mobile-btn').click(function(){
    if($('.more-helpful-links').is(":visible")){
      $('.more-helpful-links').slideUp('slow')
      iconClass = $('.helpful-link-mobile-btn').find('.icon-chevron-up')
      iconClass.removeClass("icon-chevron-up").addClass('icon-chevron-down')
    } else {
      $('.more-helpful-links').slideDown('slow')
      iconClass = $('.helpful-link-mobile-btn').find('.icon-chevron-down')
      iconClass.removeClass("icon-chevron-down").addClass('icon-chevron-up')
    }
  });
});
