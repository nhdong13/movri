window.ST = window.ST || {};

window.ST.BlockedDates = (function() {
  function addBlockedDates() {
    $("#start-date-blocked").on("change", function () {
      var rowBlockedDates = $("#start-date-blocked").val() + "," + $("#end-date-blocked").val();
      $("#listing_manually_blocked_dates").val(rowBlockedDates);
    });

    $("#end-date-blocked").on("change", function () {
      var rowBlockedDates = $("#start-date-blocked").val() + "," + $("#end-date-blocked").val();
      $("#listing_manually_blocked_dates").val(rowBlockedDates);
    });
  }
  return {
    addBlockedDates: addBlockedDates
  };
})();
