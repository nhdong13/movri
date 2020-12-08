// Custom person and listing autocomplete
$.ui.autocomplete.prototype._renderItem = function (ul, item) {
  if (ul.context.className.includes('product-name-list')) {
    return $("<li></li>")
      .data("item.autocomplete", item.id)
      .append($("<a>" + item.title + "</a>").html(item.label))
      .appendTo(ul);
  } else {
    return $("<li></li>")
      .data("item.autocomplete", item.id)
      .append($("<a>" + item.given_name + "<br>" + item.email + "</a>").html(item.label))
      .appendTo(ul);
  }
};

// Person autocomplete
$.getJSON("/admin/user_fields/person_profile", function(data) {
  source = []
  data.forEach(function(item){ source.push({ value: item.given_name, id: item.id, given_name: item.given_name, email: item.email })})

  $('#customer_name').autocomplete({
    minLength: 0,
    source: source,
    messages: {
      noResults: '',
      results: function(amount) { return '' }
    },
    focus: function(event, ui) {
      $('#customer_name').val(ui.item.given_name)
    },
    response: function (event, ui) {
      ui.content.push({
        label: '<i class="icon-plus"></i> <a href="#create-new-customer-modal" id="create-new-customer" rel="modal:open">Create new customer</a>',
        button: true
      });
    },
    select: function (event, ui) {
      if (ui.item.button) {
        event.preventDefault();
      } else {
        transaction_id = $('#draft_order_id').data("id");

        $.ajax({
          url: "/admin/user_fields/person_information.js",
          method: "GET",
          data: {
            id: ui.item.id,
            transaction_id: transaction_id
          },
          complete: function(){
            $('#craft-order-product-list .icon-times').on('click', function(e){
              $(e.target).parents('#craft-order-product-list').remove()
            })

            $('#draft_order_person_id').val(ui.item.id)

            $('.create-address').on('click', function(e){
              address_type = $(e.currentTarget).attr('data-attribute')
              $('#create-customer-address-modal').on($.modal.OPEN, function(){
                $('#create-customer-address-modal #transaction_address_address_type').attr("value", address_type)
              })
            })


          }
        })
      }
    }
  }).autocomplete('widget').addClass('person-name-list')
})

// Listing autocomplete
$.getJSON("/admin/communities/1/listings", function(data) {
  source = []
  data.forEach(function(item){
    source.push({
      value: item.title,
      lable: item.title,
      id: item.id
    })
  })

  $('#product_name').autocomplete({
    minLength: 0,
    source: source,
    messages: {
      noResults: '',
      results: function() { return '' }
    },
    select: function(event, ui){
      var id = ui.item.id
      var transaction_id = $('#draft_order_id').data("id");
      $.ajax({
        url: "/admin/communities/1/transactions/add_listing_to_draft_order.js",
        method: "POST",
        data: {
          transaction_id: transaction_id,
          ids: [id]
        },
      })
    }
  }).autocomplete('widget').addClass('product-name-list')
})

$('#review-email').on('click', function(){
  transaction_id = $('#draft_order_id').data("id");
  data = {
    transaction_id: transaction_id,
    to: $('#receiver').val(),
    custom_message: $('#custom_message').val(),
  }

  $.ajax({
    url: '/admin/communities/1/emails/review_email.js',
    data: data
  })
})

$('#send-notification').on('click', function(){
  transaction_id = $('#draft_order_id').data("id");
  data = {
    to: $('#receiver').val(),
    custom_message: $('#custom_message').val(),
    person_id: $('#person_id').val(),
    transaction_id: transaction_id
  }

  $.ajax({
    url: "/admin/communities/1/emails/sent_invoice_email",
    data: data
  })
})

var transaction_id = $('#draft_order_id').data("id");
$('.save-line-item-btn').on('click', function(){
  var data = {
    title: $('.new-custome-listing-title').val(),
    price: $('.new-custome-listing-price').val(),
    quantity: $('.new-custome-listing-quantity').val(),
    transaction_id: transaction_id
  }

  $.ajax({
    url: "/admin/communities/1/transactions/create_new_custom_item",
    method: "POST",
    data: data,
  })
})

$('body').on('change', '.craft-order-price, .craft-order-quantity', function(e){
  $parent = $(this).parents("tr")
  price = $parent.find(".craft-order-price").val();
  quantity = $parent.find(".craft-order-quantity").val();
  id = $parent.data("id")
  transaction_id = $('#draft_order_id').data("id");
  $.ajax({
    url: "/admin/communities/1/transactions/update_draft_order_items.js",
    method: "POST",
    data: {
      transaction_id: transaction_id,
      price: price,
      quantity: quantity,
      transaction_item_id: id
    },
  })
});

$('body').on('change', '.draft-custom-item-price, .draft-custom-item-quantity', function(e){
  $parent = $(this).parents("tr")
  price = $parent.find(".draft-custom-item-price").val();
  quantity = $parent.find(".draft-custom-item-quantity").val();
  id = $parent.data("id")
  transaction_id = $('#draft_order_id').data("id");
  $.ajax({
    url: "/admin/communities/1/transactions/update_draft_order_custom_items.js",
    method: "POST",
    data: {
      transaction_id: transaction_id,
      price: price,
      quantity: quantity,
      custom_item_id: id
    },
  })
});

$('body').on('click', '.remove-draft-listing-item', function(e){
  $parent = $(this).parents("tr")
  id = $parent.data("id")
  transaction_id = $('#draft_order_id').data("id");
  $.ajax({
    url: "/admin/communities/1/transactions/remove_draft_order_items.js",
    method: "POST",
    data: {
      transaction_id: transaction_id,
      transaction_item_id: id
    },
  })
});

$('body').on('click', '.remove-draft-custom-item', function(e){
  $parent = $(this).parents("tr")
  id = $parent.data("id")
  transaction_id = $('#draft_order_id').data("id");
  $.ajax({
    url: "/admin/communities/1/transactions/remove_draft_order_custom_items.js",
    method: "POST",
    data: {
      transaction_id: transaction_id,
      custom_item_id: id
    },
  })
});

$('.add-to-order-button').on('click', function(){
  var ids = []

  $('.products input:checked').map(function(i, el){
    ids.push($(el).val())
  });

  $('#craft-order-product-list .ids').map(function(i, el){
    ids.push($(el).val())
  })
  var transaction_id = $('#draft_order_id').data("id");
  $.ajax({
    url: "/admin/communities/1/transactions/add_listing_to_draft_order.js",
    method: "POST",
    data: {
      ids: ids,
      transaction_id:  transaction_id
    },
  })
})

$("body").on('click', '.add-tax', function() {
  if($('#header-toggle-menu-tax #tax').prop('checked')) {
    will_charge_taxes = true
  } else {
    will_charge_taxes = false
  }
  var transaction_id = $('#draft_order_id').data("id");
  tax_percent = $('#tax_percent').val()
  $.ajax({
    url: "/admin/communities/1/transactions/calculate_taxes.js",
    method: "POST",
    data: {
      transaction_id:  transaction_id,
      will_charge_taxes: will_charge_taxes,
      tax_percent: tax_percent
    },
  })
})

$("body").on('click', '.remove-draft-order-discount', function() {
  var transaction_id = $('#draft_order_id').data("id");
  $.ajax({
    url: "/admin/communities/1/transactions/remove_draft_order_discount.js",
    method: "POST",
    data: {
      transaction_id: transaction_id,
    },
  })
})

// add discount to draft order
$("body").on('click', '.add-discount-btn', function() {
  discount_value = $('#discount_percent').val()
  reason = $('#reason').val()
  transaction_id = $('#draft_order_id').data("id");
  if($('.draft-discount-percent').hasClass('draft-discount-active')){
    discount_type = 'percent'
  }else{
    discount_type = 'value'
  }

  $.ajax({
    url: "/admin/communities/1/transactions/add_discount_to_draft_order.js",
    method: "POST",
    data: {
      discount_value: discount_value,
      reason: reason,
      transaction_id:  transaction_id,
      discount_type: discount_type
    },
  })

  $('.remove').removeClass('dp-none')
  $('.close').addClass('dp-none')
})

// add discount to draft order
$("body").on('click', '.draft-discount-percent, .draft-discount-value', function() {
  if($(this).hasClass("draft-discount-active")){

  }else{
    $('.draft-discount-percent, .draft-discount-value').removeClass('draft-discount-active')
    $(this).addClass('draft-discount-active')
  }
})

$("body").on('click', '.open-discount-modal', function() {
  $("#header-toggle-menu-discount").toggle("show");
})

$("body").on('click', '.close-draft-discount-modal', function() {
  $("#header-toggle-menu-discount").toggle("hide");
})

$("body").on('click', '.open-draft-shipping-modal', function() {
  $("#header-toggle-menu-shipping").toggle("show");
})

$("body").on('click', '.close-draft-shipping-modal', function() {
  $("#header-toggle-menu-shipping").toggle("hide");
})

$("body").on('click', '.open-draft-taxes-modal', function() {
  $("#header-toggle-menu-tax").toggle("show");
})

$("body").on('click', '.close-draft-taxes-modal', function() {
  $("#header-toggle-menu-tax").toggle("hide");
})

$('body').on('click', '#shipping_false', function(){
  $('#custom_rate_name').removeAttr('disabled')
  $('#shipping_price').removeAttr('disabled')
})

$('body').on('click', '#shipping_true', function(){
   $('#custom_rate_name').attr({disabled: true})
  $('#shipping_price').attr({disabled: true})
})

$('body').on('click', '#update-customer-email', function(){
  email = $('#new_person_email').val()
  person_id = $('#edit_email_person_id').val()
  $.ajax({
    url: `/admin/communities/1/customers/${person_id}.js`,
    method: "PUT",
    data: {
      person: {
        email: email
      }
    },
  })
})

$('body').on('click', '.add-shipping', function(){
  if ($('#shipping_false').is(':checked')) {
    free_shipping = false
  } else {
    free_shipping = true
  }
  var transaction_id = $('#draft_order_id').data("id");
  custom_rate_name = $('#custom_rate_name').val()
  shipping_price = $('#shipping_price').val()
  $.ajax({
    url: "/admin/communities/1/transactions/add_shipping_fee_to_draft_order.js",
    method: "POST",
    data: {
      free_shipping: free_shipping,
      custom_rate_name: custom_rate_name,
      shipping_price:  shipping_price,
      transaction_id: transaction_id
    },
  })
})