window.ST = window.ST || {};

(function(module) {
  /* global disable_submit_button */
  /* global set_textarea_maxlength */
  /* global auto_resize_text_areas */
  /* jshint eqeqeq: false */ // Some parts of the code in this file actually compares number that is string to a number

  // Update the state of the new listing form based on current status
  function  update_listing_form_view(locale, attribute_array, listing_form_menu_titles, ordered_attributes, selected_attributes) {
    // Hide everything
    $('a.selected').addClass('hidden');
    $('a.option').addClass('hidden');

    // Display correct selected attributes
    $('.selected-group').each(function() {
      if (selected_attributes[$(this).attr('name')] != null) {
        $(this).find('a.selected[data-id=' + selected_attributes[$(this).attr('name')] + ']').removeClass('hidden');
      }
    });

    // Display correct attribute menus and their titles
    var title = "";
    var shouldLoadForm = false;
    if (should_show_menu_for("category", selected_attributes, attribute_array)) {
      title = listing_form_menu_titles["category"];
      display_option_group("category", selected_attributes, attribute_array);
    } else if (should_show_menu_for("subcategory", selected_attributes, attribute_array)) {
      title = listing_form_menu_titles["subcategory"];
      display_option_group("subcategory", selected_attributes, attribute_array);
    } else if (should_show_menu_for("children_category", selected_attributes, attribute_array)) {
      title = listing_form_menu_titles["children_category"];
      display_option_group("children_category", selected_attributes, attribute_array);
    } else if (should_show_menu_for("listing_shape", selected_attributes, attribute_array)) {
      title = listing_form_menu_titles["listing_shape"];
      display_option_group("listing_shape", selected_attributes, attribute_array);
    } else {
      shouldLoadForm = true;
    }
    $('h2.listing-form-title').html(title);

    return shouldLoadForm;
  }



  // Return subcategories for given category.
  // Returns empty array if there are no subcategories.
  function get_subcategories_for(category_id, category_array) {
    return _.chain(category_array)
      .filter(function(category) {
        return category["id"] == category_id;
      })
      .filter(function(category) {
        return category["subcategories"] !== undefined;
      })
      .map(function(category) {
        return category["subcategories"];
      })
      .flatten()
      .value();
  }

  function get_children_categories_for(subcategory_id, category_array) {
    return _.chain(category_array)
      .filter(function(category) {
        return category["id"] == subcategory_id;
      })
      .filter(function(category) {
        return category["children_categories"] !== undefined;
      })
      .map(function(category) {
        return category["children_categories"];
      })
      .flatten()
      .value();
  }

  // Check if category has a certain subcategory
  function has_subcategory(category_id, subcategory_id, attribute_array) {
    var subcategories = get_subcategories_for(category_id, attribute_array);
    return _.any(subcategories, function(subcategory) {
      return subcategory['id'] == subcategory_id;
    });
  }

  function has_children_category(subcategory_id, children_category_id, attribute_array) {
    var children_categories = get_children_categories_for(subcategory_id, attribute_array);
    return _.any(children_categories, function(children_category) {
      return children_category['id'] == children_category_id;
    });
  }

  // Returns true if given attribute has been selected
  function attribute_selected(attribute, selected_attributes) {
    return (selected_attributes[attribute] != null);
  }

  // Returns the object that has the given id
  // from an array of objects
  function find_by_id(id, array) {
    return _.find(array, function(item) {
      return item.id === id;
    });
  }

  // Return listing shapes of given category (expects
  // that this category does not have subcategories)
  function get_listing_shapes_for_category(category_id, category_array) {
    var category = find_by_id(Number(category_id), category_array);
    return category["listing_shapes"];
  }

  // Returns listing shape of given subcategory
  function get_listing_shapes_for_subcategory(category_id, subcategory_id, category_array) {
    var category = find_by_id(Number(category_id), category_array);
    var subcategory = find_by_id(Number(subcategory_id), category["subcategories"]);
    return subcategory["listing_shapes"];
  }

  // Returns listing shape of given children category
  function get_listing_shapes_for_children_category(subcategory_id, children_category_id, category_array) {
    var subcategory = find_by_id(Number(subcategory_id), category_array);
    var children_category = find_by_id(Number(children_category_id), subcategory["children_categories"]);
    return children_category["listing_shapes"];
  }

  // Return true if given menu should be displayed
  function should_show_menu_for(attribute, selected_attributes, attribute_array) {
    if (attribute_selected(attribute, selected_attributes)) {
      return false;
    } else if (attribute == "category") {
      if (attribute_array.length < 2) {
        // If there is exactly 1 category, it should be marked automatically as selected,
        // without showing the form.
        if (attribute_array.length == 1) {
          selected_attributes["category"] = attribute_array[0]["id"];
        }
        return false;
      } else {
        return true;
      }
    } else if (attribute == "subcategory") {
      if (should_show_menu_for("category", selected_attributes, attribute_array)) {
        return false;
      } else {
        var subcategories = get_subcategories_for(selected_attributes["category"], attribute_array);
        if (subcategories.length < 2) {
          // If there is exactly 1 subcategory, it should be marked automatically as selected,
          // without showing the form.
          if (subcategories.length == 1) {
            selected_attributes["subcategory"] = subcategories[0]["id"];
          }
          return false;
        } else {
          return true;
        }
      }
    } else if (attribute == "children_category") {
      if (should_show_menu_for("category", selected_attributes, attribute_array)) {
        return false;
      } else {
        var children_categories = get_children_categories_for(selected_attributes["subcategory"], attribute_array);
        if (children_categories.length < 2) {
          if (children_categories.length == 1) {
            selected_attributes["children_category"] = children_categories[0]["id"];
          }
          return false;
        } else {
          return true;
        }
      }
    } else if (attribute == "listing_shape") {
      if (should_show_menu_for("category", selected_attributes, attribute_array)) {
        return false;
      } else if (should_show_menu_for("subcategory", selected_attributes, attribute_array)) {
        return false;
      } else if (should_show_menu_for("children_category", selected_attributes, attribute_array)) {
        return false;
      } else {
        var listing_shapes;
        if (attribute_selected("children_category", selected_attributes)) {
          listing_shapes = get_listing_shapes_for_children_category(selected_attributes["subcategory"], selected_attributes["children_category"], attribute_array);
        } else if (attribute_selected("subcategory", selected_attributes)) {
          listing_shapes = get_listing_shapes_for_subcategory(selected_attributes["category"], selected_attributes["subcategory"], attribute_array);
        } else {
          listing_shapes = get_listing_shapes_for_category(selected_attributes["category"], attribute_array);
        }
        // If there is exactly 1 listing shape, it should be marked automatically as selected,
        // without showing the form
        if (listing_shapes.length === 1) {
          selected_attributes["listing_shape"] = listing_shapes[0]["id"];
        }
        return (listing_shapes.length > 1);
      }
    }
  }

  function addPackingDimension() {
    $(document).on('click', '.add-piece-button', function() {
      $.ajax({
        url: '/add_packing_dimension',
        type: 'POST',
        dataType: 'script',
        success: function() {
          return;
        }
      });
    });
  }

  function removePackingDimension() {
    $(document).on('click', '.remove-packing-dimension', function() {
      var id = $(this).attr('id');
      var packingDimension = $('#' + id);
      $(packingDimension).remove();
      $('.packing-dimension-attributes').append("<input type='hidden' value='1' name='listing[packing_dimensions_attributes]["+ id +"][_destroy]' id='listing_packing_dimensions_attributes_"+ id +"_destroy'>");
    });
  }

  function loadSelectize() {
    updateAccessoriesSelectize();

    $('.listing_accessories').selectize({
      create: false,
      delimiter: ',',
      closeAfterSelect: true,
      load: function(query, callback) {
        emptyRenderResult();
        if (!query.length) {
          return callback()
        }
        _this_load = this
        $.ajax({
          url: "/search_listing_by_name",
          type: 'get',
          data:
          {
            q: query
          },
          success: function(res) {
            renderResult(res)
            _this_load.loadedSearches = {};
          }
        });
      }
    })

    $('.listing_alternatives').selectize({
      create: false,
      delimiter: ',',
      closeAfterSelect: true,
      load: function(query, callback) {
        emptyRecommendedAlternativesResult();
        if (!query.length) {
          return callback()
        }
        _this_load = this
        $.ajax({
          url: "/search_listing_by_name",
          type: 'get',
          data:
          {
            q: query
          },
          success: function(res) {
            renderRecommendedAlternativesResult(res)
            _this_load.loadedSearches = {};
          }
        });
      }
    })

    $('.listing_collection').selectize({
      create: false,
      delimiter: ',',
      closeAfterSelect: false,
    });

    function renderResult(res) {
      html = ''
      $.each(res, function(idx, result) {
        html += '<li class="add-recommended-accessory" data-id="'+ result.id +'">'+ result.title +'</li>';
      });
      $('.selectize-recommended-accessories-result').html(html);
    }

    function renderRecommendedAlternativesResult(res) {
      html = ''
      $.each(res, function(idx, result) {
        html += '<li class="add-recommended-alternative" data-id="'+ result.id +'">'+ result.title +'</li>';
      });
      $('.selectize-recommended-alternatives-result').html(html);
    }

    function emptyRenderResult() {
      $('.selectize-recommended-accessories-result').empty();
    }

    function emptyRecommendedAlternativesResult() {
      $('.selectize-recommended-alternatives-result').empty();
    }

    $('.recommended-accessories-wrap .selectize-input input').on('focusin', function() {
      emptyRenderResult();
      $('.selectize-recommended-accessories-result').css('display', 'block');
    })

    $('.recommended-alternatives-wrap .selectize-input input').on('focusin', function() {
      emptyRecommendedAlternativesResult();
      $('.selectize-recommended-alternatives-result').css('display', 'block');
    })

    $('.selectize-recommended-accessories-result').on('click', '.add-recommended-accessory', function() {
      var id = $(this).data('id');
      var title = $(this).text();
      if (idExists(id) != true) {
        html =  '<li class="cursor-pointer background" draggable="false" style="" data-id="'+ id +'" >'+
                  '<div class="recommended-accessory-item row m-0 pl-0 pr-0">' +
                    '<div class="col-1 p-0 m-0">' +
                      '<span>' +
                        '<i class="fa fas fa-ellipsis-v" style="margin-right: 3px"></i>' +
                        '<i class="fa fas fa-ellipsis-v"></i>' +
                      '</span>' +
                    '</div>' +
                    '<div class="col-9 p-0 m-0">' + title + '</div>' +
                    '<div class="col-2 p-0 m-0 text-right">'+
                      '<i class="icon-remove" data-id="'+ id +'"></i>' +
                    '</div>'+
                  '</div>'+
                '</li>';
        $('#recommendedAccessoriesSortableList').append(html);
        updateAccessoriesSelectize();
        var listingId = document.getElementById('recommendedAccessoriesSortableList').dataset.listingId
        var paramsData = {listing_accessory_id: id}
        $.ajax({
          url: `/listings/${listingId}/add_accessories`,
          type: 'POST',
          data: paramsData,
          success: function() {
            return;
          }
        });
      };
      $('.selectize-recommended-accessories-result').css('display', 'none');
    });

    $('.selectize-recommended-alternatives-result').on('click', '.add-recommended-alternative', function() {
      var id = $(this).data('id');
      var title = $(this).text();
      if (idExists(id) != true) {
        html =  '<li class="cursor-pointer background" draggable="false" style="" data-id="'+ id +'" >'+
                  '<div class="recommended-alternative-item row m-0 pl-0 pr-0">' +
                    '<div class="col-1 p-0 m-0">' +
                      '<span>' +
                        '<i class="fa fas fa-ellipsis-v" style="margin-right: 3px"></i>' +
                        '<i class="fa fas fa-ellipsis-v"></i>' +
                      '</span>' +
                    '</div>' +
                    '<div class="col-9 p-0 m-0">' + title + '</div>' +
                    '<div class="col-2 p-0 m-0 text-right">'+
                      '<i class="icon-remove" data-id="'+ id +'"></i>' +
                    '</div>'+
                  '</div>'+
                '</li>';
        $('#recommendedalternativesSortableList').append(html);
        updateAlternativesSelectize();
        var listingId = document.getElementById('recommendedalternativesSortableList').dataset.listingId
        var paramsData = {listing_alternative_id: id}
        $.ajax({
          url: `/listings/${listingId}/add_alternatives`,
          type: 'POST',
          data: paramsData,
          success: function() {
            return;
          }
        });
      };
      $('.selectize-recommended-alternatives-result').css('display', 'none');
    });

    $('.submit-new-listing').click(function(e){
      e.preventDefault();
      var selected_attributes = selectedAttributesFromQueryParams(window.location.search);
      var attrs = hashCompact(selected_attributes);
      $("#category_id").val(attrs.category)
      $("#subcategory_id").val(attrs.subcategory)
      $("#children_category_id").val(attrs.children_category)
      $(this).parents('form').submit()
    });

    function idExists(id) {
      return $('.recommended-accessories-list').find('[data-id='+ id +']').length != 0;
    }

    function updateAccessoriesSelectize() {
      listAccessory = [];
      $.each($('.recommended-accessory-item'), function(_idx, el) {
        listAccessory.push($(el).data('id'));
      });
      $('.listing-accessories-hidden').val(listAccessory.join(','))
    }

    function updateAlternativesSelectize() {
      listAlternative = [];
      $.each($('.recommended-alternative-item'), function(_idx, el) {
        listAlternative.push($(el).data('id'));
      });
      $('.listing-alternatives-hidden').val(listAlternative.join(','))
    }

    $(document).on('click', '.recommended-accessory-item .icon-remove', function() {
      var id = $(this).data('id');
      $('.recommended-accessories-list').find('[data-id='+ id + ']').remove();
      updateAccessoriesSelectize();
      var listingId = document.getElementById('recommendedAccessoriesSortableList').dataset.listingId
      paramsData = {listing_accessory_id: id}
      $.ajax({
        url: `/listings/${listingId}/remove_accessory`,
        type: 'PUT',
        data: paramsData,
        success: function() {
          return;
        }
      });
    });

    $(document).on('click', '.recommended-alternative-item .icon-remove', function() {
      var id = $(this).data('id');
      $('.recommended-alternatives-list').find('[data-id='+ id + ']').remove();
      updateAlternativesSelectize();
      var listingId = document.getElementById('recommendedalternativesSortableList').dataset.listingId
      paramsData = {listing_alternative_id: id}
      $.ajax({
        url: `/listings/${listingId}/remove_alternative`,
        type: 'PUT',
        data: paramsData,
        success: function() {
          return;
        }
      });
    });
  }

  // init tags field for new listing
  function initTagsFieldForNewListing() {
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

  // Ajax call to display listing form after categories and
  // listing shape has been selected
  function display_new_listing_form(selected_attributes, options) {
    $.get(options.new_form_content_path, selected_attributes, function(data) {
      $('.js-form-fields').html(data);
      $('.js-form-fields').removeClass('hidden');
      loadSelectize();
      initTagsFieldForNewListing();
    });
  }

  function display_edit_listing_form(selected_attributes, locale, id) {
    var edit_listing_path = '/' + locale + '/listings/edit_form_content';
    var request_params = _.assign({}, selected_attributes, {id: id});
    $.get(edit_listing_path, request_params, function(data) {
      $('.js-form-fields').html(data);
      $('.js-form-fields').removeClass('hidden');
      loadSelectize();
    });
  }

  addPackingDimension();
  loadSelectize();
  removePackingDimension();

  // Check if selected category or subcategory has certain listing shape
  function has_listing_shape(selected_attributes, listing_shape_id, attribute_array) {
    // If subcategory is selected, loop through listing shapes of that subcategory
    var listing_shapes;
    if (attribute_selected("subcategory", selected_attributes)) {
      listing_shapes = get_listing_shapes_for_subcategory(selected_attributes["category"], selected_attributes["subcategory"],attribute_array);
      // If there's no subcategory, it means this top level category has no subcategories.
      // Thus, loop through listing_shapes of top level category.
    } else {
      listing_shapes = get_listing_shapes_for_category(selected_attributes["category"] ,attribute_array);
    }
    return _.any(listing_shapes, function(listing_shape) {
      return listing_shape['id'] == listing_shape_id;
    });
  }

  // Displays the given menu where category or listing shape can be selected
  function display_option_group(group_type, selected_attributes, attribute_array) {
    $('.option-group[name=' + group_type + ']').children().each(function() {
      if (group_type == "category") {
        $(this).removeClass('hidden');
      } else if (group_type == "subcategory") {
        if (has_subcategory(selected_attributes["category"], $(this).attr('data-id'), attribute_array)) {
          $(this).removeClass('hidden');
        }
      } else if (group_type == "children_category") {
        if (has_children_category(selected_attributes["subcategory"], $(this).attr('data-id'), attribute_array)) {
          $(this).removeClass('hidden');
        }
      } else if (group_type == "listing_shape") {
        if (has_listing_shape(selected_attributes, $(this).attr('data-id'), attribute_array)) {
          $(this).removeClass('hidden');
        }
      }
    });
  }

  // Called when a link is clicked in the listing form attribute menus
  function select_listing_form_menu_link(link, locale, attribute_array, listing_form_menu_titles, ordered_attributes, selected_attributes) {

    // Update selected attributes based on the selection that has been made
    if (link.hasClass('option')) {
      selected_attributes[link.parent().attr('name')] = link.attr('data-id');
    } else {
      selected_attributes[link.parent().attr('name')] = null;
      // Unselect also all sub-attributes if certain attribute is unselected
      // (for instance, unselect subcategory if category is unselected).
      var index_found = false;
      for (var i = 0; i < ordered_attributes.length; i++) {
        if (ordered_attributes[i] == link.parent().attr('name')) {
          index_found = true;
        }
        if (index_found === true) {
          selected_attributes[ordered_attributes[i]] = null;
        }
      }
    }

    // Update form view based on the selection that has been made
    var shouldLoadForm = update_listing_form_view(locale, attribute_array, listing_form_menu_titles, ordered_attributes, selected_attributes);

    return shouldLoadForm;
  }

  var setPushState = function(selectedAttributes) {
    if(window.history == null || window.history.pushState == null ) {
      return;
    }

    var url = window.location.origin + window.location.pathname;

    window.history.pushState(selectedAttributes, null, addQueryParams(url, selectedAttributes));
  };

  var addQueryParams = function(url, selectedAttributes) {
    var attrs = hashCompact(selectedAttributes);

    if(_.isEmpty(attrs)) {
      return url;
    } else {
      var q = _.map(attrs, function(val, key) {
        return key + "=" + val;
      }).join("&");
      return [url, q].join("?");
    }
  };

  var hashCompact = function(h) {
    return _.reduce(h, function(acc, val, key) {
      if(val != null) {
        acc[key] = val;
      }
      return acc;
    }, {});
  };

  var emptySelection = {"category": null, "subcategory": null, "listing_shape": null};

  var selectedAttributesFromQueryParams = function(search) {
    if(!search) {
      return {};
    }

    var without_q = search.replace(/^\?/, ''); // Remove the first char if it's question mark
    var attrsFromQuery = _.zipObject(without_q.split("&").map(function(keyValuePair) { return keyValuePair.split("="); }));

    return _.assign({}, emptySelection, attrsFromQuery);
  };

  // Initialize the listing type & category selection part of the form
  module.initialize_new_listing_form_selectors = function(options) {
    var ordered_attributes = ["category", "subcategory", 'children_category', "listing_shape"];
    var selected_attributes = selectedAttributesFromQueryParams(window.location.search);

    // Reset the view to initial state
    var shouldLoadForm = update_listing_form_view(options.locale, options.category_tree, options.menu_titles, ordered_attributes, selected_attributes);

    if(shouldLoadForm) {
      display_new_listing_form(selected_attributes, options);
    }

    var menuStateChanged = function(shouldLoadForm) {
      if(shouldLoadForm) {
        display_new_listing_form(selected_attributes, options);
      }
    };

    // Listen for back button click
    window.addEventListener('popstate', function(evt) {
      selected_attributes = evt.state || emptySelection;

      $('.js-form-fields').addClass('hidden');
      var shouldLoadForm = select_listing_form_menu_link($(this), options.locale, options.category_tree, options.menu_titles, ordered_attributes, selected_attributes);

      menuStateChanged(shouldLoadForm);
    });

    // Listener for attribute menu clicks
    $('.new-listing-form').find('a.select').click(
      function() {
        $('.js-form-fields').addClass('hidden');
        var shouldLoadForm = select_listing_form_menu_link($(this), options.locale, options.category_tree, options.menu_titles, ordered_attributes, selected_attributes);

        setPushState(selected_attributes);

        menuStateChanged(shouldLoadForm);
      }
    );
  };

  module.initialize_edit_listing_form_selectors = function(locale, attribute_array, listing_form_menu_titles, category, subcategory, children_category, listing_shape, id) {
    var ordered_attributes = ["category", "subcategory", 'children_category', "listing_shape"];

    // Selected values (string or null required)
    category = category ? "" + category : null;
    subcategory = subcategory ? "" + subcategory : null;
    children_category = children_category ? "" + children_category : null;
    listing_shape = listing_shape ? "" + listing_shape : null;
    var selected_attributes = {"category": category, "subcategory": subcategory, 'children_category': children_category, "listing_shape": listing_shape};
    var originalSelection = _.clone(selected_attributes);
    var current_attributes = _.clone(selected_attributes);

    // Reset the view to initial state
    var shouldShowForm = update_listing_form_view(locale, attribute_array, listing_form_menu_titles, ordered_attributes, selected_attributes);

    if(shouldShowForm) {
      $('.js-form-fields').removeClass('hidden');
    }

    var menuStateChanged = function(shouldLoadForm) {
      if(shouldLoadForm) {

        var loadNotNeeded = _.isEqual(selected_attributes, current_attributes);
        current_attributes = _.clone(selected_attributes);

        if(loadNotNeeded) {
          $('.js-form-fields').removeClass('hidden');
        } else {
          $('.js-form-fields').html("");
          display_edit_listing_form(selected_attributes, locale, id);
        }
      }

    };

    // Listen for back button click
    window.addEventListener('popstate', function(evt) {
      selected_attributes = evt.state || originalSelection;

      $('.js-form-fields').addClass('hidden');
      var shouldLoadForm = select_listing_form_menu_link($(this), locale, attribute_array, listing_form_menu_titles, ordered_attributes, selected_attributes);

      menuStateChanged(shouldLoadForm);
    });

    // Listener for attribute menu clicks
    $('.new-listing-form').find('a.select').click(
      function() {
        $('.js-form-fields').addClass('hidden');
        var shouldLoadForm = select_listing_form_menu_link($(this), locale, attribute_array, listing_form_menu_titles, ordered_attributes, selected_attributes);

        setPushState(selected_attributes);
        menuStateChanged(shouldLoadForm);
      }
    );

  };

  // Initialize the actual form fields
  module.initialize_new_listing_form = function(
    fileDefaultText,
    fileBtnText,
    locale,
    share_type_message,
    date_message,
    listing_id,
    price_required,
    price_message,
    minimum_price,
    subunit_to_unit,
    minimum_price_message,
    numeric_field_names,
    listingImages,
    listingImageOpts,
    imageLoadingInProgressConfirm) {

    $('#help_valid_until_link').click(function() { $('#help_valid_until').lightbox_me({centered: true, zIndex: 1000000}); });
    $('input.title_text_field:first').focus();

    var $shipping_price_container = $('.js-shipping-price-container');
    var $shipping_checkbox = $('#shipping-checkbox');
    $shipping_checkbox.click(function() { togglePrice(); });

    var togglePrice = function(){
      if($shipping_checkbox.is(":checked")) {
        $shipping_price_container.show();
      } else {
        $shipping_price_container.hide();
      }
    };
    togglePrice(); //initialize

    var $unit = $(".js-listing-unit");

    if ($unit.length) {
      var $additionalShipping = $(".js-shipping-price-additional");

      var toggleAdditional = function() {
        var kind = $unit.find(":selected").data("kind");

        if (kind === "quantity") {
          $additionalShipping.css({display: "table"});
        } else {
          $additionalShipping.hide();
        }
      };

      $unit.change(toggleAdditional);
      toggleAdditional(); // init
    }

    var form_id = (listing_id == "false") ? "#new_listing" : ("#edit_listing_" + listing_id);

    // Is price required?
    var pr = null;
    if (price_required == "true") {
      pr = true;
    } else {
      pr = false;
    }

    var numericRules = numeric_field_names.reduce(function(rules, name) {
      var el = module.utils.findElementByName(name);
      var min = el.data("min");
      var max = el.data("max");

      rules[name] = {number_min: min, number_max: max};

      return rules;
    }, {});

    module.listingForm = $(form_id).validate({
      errorPlacement: function(error, element) {
        if (element.attr("name") == "listing[valid_until(1i)]") {
          error.appendTo(element.parent());
        } else if (element.attr("name") == "listing[price]") {
          error.appendTo(element.parent());
        } else if ($(element).hasClass("custom_field_checkbox")) {
          var container = $(element).closest(".checkbox-group-container");
          error.insertAfter(container);
        } else if ($(element).hasClass("delivery-method-checkbox")) {
          error.insertAfter($(".delivery-options-container"));
        } else if (element.attr("name") == "listing[shipping_price]") {
          error.insertAfter($(".shipping-price-default"));
        } else if (element.attr("name") == "listing[shipping_price_additional]") {
          error.insertAfter($(".js-shipping-price-additional"));
        } else {
          error.insertAfter(element);
        }
      },
      debug: false,
      rules: _.extend(numericRules, {
        "listing[title]": {required: true, minlength: 2, maxlength: 255},
        "listing[origin]": {address_validator: true},
        "listing[price]": {required: pr, money: true, minimum_price_required: [minimum_price, subunit_to_unit]},
        "listing[shipping_price]": {money: true},
        "listing[shipping_price_additional]": {money: true},
        "listing[valid_until(1i)]": { min_date: true, max_date: true }
      }),
      messages: {
        "listing[valid_until(1i)]": { min_date: date_message, max_date: date_message },
        "listing[price]": { minimum_price_required: minimum_price_message }
      },
      // Run validations only when submitting the form.
      onkeyup: false,
      onclick: false,
      onfocusout: false,
      onsubmit: true
    });

    var status = window.ST.imageUploader(listingImages, listingImageOpts).log("status returned");

    status.onValue(function(stats) {

      $('.flash-notifications').click(function() {
        $('.flash-notifications').fadeOut('slow');
      });

      if(stats.loading === 0) {
        $(".js-listing-image-loading").hide();

        if(stats.processing === 0) {
          $(".js-listing-image-loading-done").hide();
        } else {
          $(".js-listing-image-loading-done").show();
        }
      } else {
        $(".js-listing-image-loading-done").hide();
        $(".js-listing-image-loading").show();
      }
    });

    var formSubmitted = $(form_id).asEventStream("submit");
    var validFormSubmitted = formSubmitted.filter(function() {
      return $(form_id).valid();
    });

    var isLoading = status.map(function(stats) { return stats.loading > 0; });

    // This handler is used only when Image uploader is loading
    validFormSubmitted.filter(isLoading).onValue(function(e) {
      var confirmed = window.confirm(imageLoadingInProgressConfirm);

      if(!confirmed) {
        e.preventDefault();

        // This will prevent the jQuery validation submitHandler from
        // executing. Please note that the order matters. This works
        // before it's called BEFORE the submitHandler
        e.stopImmediatePropagation();
      }
    });

    // This handler is used when Image uploader is not loading
    validFormSubmitted.filter(isLoading.not()).onValue(function(e) {
      window.ST.analytics.logEvent("listing", "created");
      disable_submit_button(form_id, locale);
    });

    set_textarea_maxlength();
    auto_resize_text_areas("listing_description_textarea");

    $(form_id).addClass("js-listing-form-ready");
  };

})(window.ST);
