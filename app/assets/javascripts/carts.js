window.ST = window.ST || {};

(function(module) {
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

})(window.ST);
