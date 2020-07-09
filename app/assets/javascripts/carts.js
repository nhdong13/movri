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
  };

  $('body').on('change', ".show-cart-page .zip-code-input", function(){
    handleChangeZipCode()
    var zipcode = $(this).val()
    $.ajax({
      url: '/carts/get_shipping_rates_for_listing_items.js',
      type: "GET",
      data: { zipcode: zipcode }
    }).done(function(response) {
    }).fail(function(error) {});
  });

  function getListingSku () {
    skus = []
    _.map($('.unique-listing-sku'), function(i) {
      skus.push($(i).data("sku"))
      }
    )
    return _.uniq(skus)
  }

  function handleChangeInput() {
    $('#price-item').html("...")
    $('.promo-code-error').hide();
  }

  function handleChangeZipCode() {
    $(".show-cart-page .desktop-custom-select-shipping").hide()
    $('.shipping-box .spinner').fadeIn("slow");
  }

  $(".promo-code-field button").click(function(){
    handleChangeInput()
    skus = getListingSku()
    promoCode = $(this).parent().find('.promo-code-val').val();
    $.ajax({
      url: '/promo_codes/check_code.js',
      type: "GET",
      data: {
        code: promoCode,
        skus: skus
      }
    }).done(function(response) {
    }).fail(function(error) {});
  });

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


  $('.input-arrival-date').datepicker({
    daysOfWeekDisabled: '0',
    autoclose: true,
    startDate: new Date(),
    todayHighlight: true,
  });

  $('.input-return-date').datepicker({
    daysOfWeekDisabled: '0',
    autoclose: true,
    startDate: next_day(new Date()),
    todayHighlight: true,
  });

  function next_day(day){
    new_day = day.setDate(day.getDate() + 1);

    return new Date(new_day)
  }

  $('#cart_deatail_arrival_date, #cart_deatail_return_date').datepicker()
    .on('changeDate', function(e) {
      if(this.id == "cart_deatail_arrival_date"){
        startDate = $(this).val();
        endDate = $("#cart_deatail_return_date").val();
      }else{
        startDate = $("#cart_deatail_arrival_date").val();
        endDate = $(this).val();
      }
      if (!startDate || !endDate) {
        return;
      }
      changeBookingDayUrl = "/en/change_cart_detail_booking_days.js";
      promoCode = getPromoCode()
      $.ajax({
        url: changeBookingDayUrl,
        type: "PUT",
        data: {
          start_date: startDate,
          end_date: endDate,
          code: promoCode
        }
      })
    }
  );

  function getPromoCode() {
    var promoCode = []
    _.map($('.promo-code-val'), function(i) {
      if(!$(i).val() == ""){
        promoCode.push($(i).val())
      }
    })
    return promoCode[0];
  }

  $('body').on("change", ".mobile-number-item-in-cart-detail, .cart-detail-item-quantity", function () {
    var promoCode = getPromoCode();
    var id = event.target.id;
    var total = $("#" + id).val();
    var listingId = id.split("-").pop();
    var plusItemUrl = "/en/listings/" + listingId + "/change_number_of_item.js";
    $.ajax({
      url: plusItemUrl,
      type: "POST",
      data: {
        total: total,
        promo_code: promoCode
      }
    }).done(function(response) {}).fail(function(error) {})
  });

  $('.mobile-number-item-in-cart-detail, .cart-detail-item-quantity').keypress(function(event){
    if(event.which != 8 && isNaN(String.fromCharCode(event.which))){
      event.preventDefault();
    }
  });

  $('body').on('change', '.shipping-box #select_shipping', function(){
    changeCartSelectShippingURL = "/en/change_cart_select_shipping.js";
    promoCode = getPromoCode();
    shipping_type = $(this).val();
    $.ajax({
      url: changeCartSelectShippingURL,
      type: "GET",
      data: {
        shipping_type: shipping_type,
        code: promoCode
      }
    })
  });

  $('body').on('click', '.btn-checkout', function(){
    createTransactionURL = "/en/transactions";
    instructions = $('#instructions').val();
    promoCode = getPromoCode();
    $.ajax({
      url: createTransactionURL,
      type: "POST",
      dataType: "json",
      data: {
        instructions: instructions,
        code: promoCode
      }
    }).done(function(response) {
       window.location.href = response.redirect_url
    }).fail(function(error) {})
  });

})(window.ST);
