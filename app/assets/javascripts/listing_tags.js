window.ST = window.ST || {};


window.ST.ListingTags = (function() {
  function addTagWithGetIt() {
    $(document).ready(function() {
      $("#list_tags_selected").tagit({
        beforeTagAdded: function(event, ui) {
          var tags = $('#listing_tags').val();
          // add to hidden field
          if (!tags.length) {
            tags = ui.tagLabel
          } else {
            tags = tags + "," + ui.tagLabel;
          }
          // get array tags from string
          var tagsArray = tags.split(',');
          // get unique array
          var uniqTagsArray = [...new Set(tagsArray)];
          // convert unique array to string
          var uniqTags = uniqTagsArray.join(',');

          $('#listing_tags').val(uniqTags);
        },
        beforeTagRemoved: function(event, ui) {
          var removeTag = ui.tagLabel;
          // get list tags as an array
          var tags = $('#listing_tags').val().split(',');

          // return new array without removed item
          tags = tags.filter(function(item) {
            return item !== removeTag
          })

          // join array to string
          $('#listing_tags').val(tags.join(','));
        }
      });
    });
  }

  return {
    addTagWithGetIt: addTagWithGetIt
  };
})();
