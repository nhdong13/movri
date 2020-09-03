window.ST = window.ST || {};


window.ST.ListingTags = (function() {
  function initTagsForEditListing() {
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
        // get unique array from tags array
        var uniqTagsArray = tagsArray.reduce(function(a,b){
          if (a.indexOf(b) < 0 ) a.push(b);
          return a;
        },[]);
        // convert unique array to string
        var uniqTags = uniqTagsArray.join(',');

        // add new value to hidden field
        $('#listing_tags').val(uniqTags);
      },
      beforeTagRemoved: function(event, ui) {
        var removeTag = ui.tagLabel;
        // get list tags as an array
        var tags = $('#listing_tags').val().split(',');

        // return new array without removed item
        tags = tags.filter(function(item) {
          return item !== removeTag
        });
        // join array to string
        $('#listing_tags').val(tags.join(','));
      }
    });
  }

  function handleChangeItemType() {
    $('body').on('change', '#listing_accessory_item_type', function(){
      listing_type = $(this).val().toLowerCase()
      $('.accessories-list').hide()
      $("." + listing_type).slideDown('slow')
    })
  }

  function handleLoadItemType() {
    listing_type = $('#listing_accessory_item_type').val().toLowerCase()
    $('.accessories-list').hide()
    if(listing_type.length){
      $("." + listing_type).slideDown('slow')
    }
  }

  return {
    initTagsForEditListing: initTagsForEditListing,
    handleChangeItemType: handleChangeItemType,
    handleLoadItemType: handleLoadItemType
  };
})();
