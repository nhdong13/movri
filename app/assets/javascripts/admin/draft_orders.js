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
        $.ajax({
          url: "/admin/user_fields/person_information.js",
          method: "GET",
          data: {
            id: ui.item.id
          },
          complete: function(){
            $('.product-list .icon-times').on('click', function(e){
              $(e.target).parents('.product-list').remove()
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
      var ids = $(".ids").map(function(){return $(this).val();}).get();
      ids.push(ui.item.id)

      $.ajax({
        url: "/admin/communities/1/listings/get_listings.js",
        method: "GET",
        data: {
          ids: ids
        },
        complete: function() {
          $('.price').on('change', function(e){
            var total_price = $(e.target).val() * $(e.target).closest('tr').find('.quantity').val()
            $(e.target).closest('tr').find('.total-price').text(`$${total_price}`)
          })

          $('.quantity').on('change', function(e){
            $(e.target).closest('tr').find('.total-price').text(`$${$(e.target).val() * $(e.target).closest('tr').find('.price').val()}`)
          })

          $('.icon-times').on('click', function(e){
            $(e.target).closest('tr').remove()
          })
        }
      })
    }
  }).autocomplete('widget').addClass('product-name-list')
})

$('#review-email').on('click', function(){
  var data = {
    receiver: $('#receiver').val(),
    sender: $('#sender').val(),
    subject: $('#subject').val(),
    custom_message: $('#custom_message').val()
  }

  $.ajax({
    url: '/admin/communities/1/emails/review_email.js',
    data: data
  })
})

$('#send-notification').on('click', function(){
  var data = {
    to: $('#receiver').val(),
    person_id: $('#person_id').val()
  }

  $.ajax({
    url: "/admin/communities/1/emails/sent_invoice_email",
    data: data
  })
})

$('.add-to-order-button').on('click', function(){
  var ids = []

  $('.products input:checked').map(function(i, el){
    ids.push($(el).val())
  });

  $('.product-list .ids').map(function(i, el){
    ids.push($(el).val())
  })

  $.ajax({
    url: "/admin/communities/1/listings/get_listings.js",
    method: "GET",
    data: { ids: ids },
    complete: function(){
      $('.product-list .icon-times').on('click', function(e){
        $(e.target).parents('.product-list').remove()
      })
    }
  })
})