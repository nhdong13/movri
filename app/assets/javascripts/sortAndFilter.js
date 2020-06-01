window.ST = window.ST || {};

(function(module) {
  module.initSortAndFilter = function() {
    onSelectSort();
  };

  function onSelectSort () {
    $('#sort_listing').on('change', function() {
      var loadCategories = "/categories.js";
      var sortValue =  $(this).val()
      $.ajax({
        url: loadCategories,
        type: "GET",
        data: {
          sort: sortValue
        }
      }).done(function(response) {
        if (response.success === true) {
        }
      }).fail(function(error) {
        console.log("Error:", error);
      });
    });
  }
})(window.ST);
