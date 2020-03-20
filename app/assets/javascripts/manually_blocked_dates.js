window.ST = window.ST || {};

window.ST.BlockedDates = (function() {
  function addBlockedDates() {
    // append row for listing blocked dates table
    $(".add-blocked-dates-button").on("click", function () {
      var rowTable = "<tr class='row-start-to-end'>"
        + "<td class='start-blocked-date-item'>"
          + $("#start-date-blocked").val()
        + "</td>"
        + "<td class='end-blocked-date-item'>"
          + $("#end-date-blocked").val()
        + "</td>"
        + "<td class='delete-blocked-dates'>"
          + "<i class='icon-remove' style='cursor: pointer;'></i>"
        + "</td>"
      + "</tr>";

      $("#list-blocked-dates-table").append(rowTable);

      var listBlockedDates = getListBlockedDates();
      $("#listing_manually_blocked_dates").val(listBlockedDates);
    });

    // remove a row from listing blocked dates table
    $("#list-blocked-dates-table").on("click", '.delete-blocked-dates', function() {
      $(this).closest('tr.row-start-to-end').remove();
      var listBlockedDates = getListBlockedDates();
      $("#listing_manually_blocked_dates").val(listBlockedDates);
    });

    $(".get-blocked-dates-button").on("click", function () {
      $(this).closest('tr').children('td.two').text();
    });

  }

  // get blocked dates and convert to string
  function getListBlockedDates () {
    var listBlockedDates = "";

    $('#list-blocked-dates-table .row-start-to-end').each(function() {
      var start_date = $(this).find(".start-blocked-date-item").html();
      var end_date = $(this).find(".end-blocked-date-item").html();
      var strStartToEnd = start_date.trim() + "," + end_date.trim();

      if (listBlockedDates.length) {
        listBlockedDates = listBlockedDates + "&" + strStartToEnd;
      } else {
        listBlockedDates = strStartToEnd;
      }
    });

    return listBlockedDates;
  }

  return {
    addBlockedDates: addBlockedDates
  };
})();
