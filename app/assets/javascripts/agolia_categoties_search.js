window.ST = window.ST || {};

(function(module) {
  var initAgoliaSearchCategoties = function() {
  // ====================================================================================
    function getCategorySlug(name) {
      return name
        .split(' ')
        .map(encodeURIComponent)
        .join('+');
    }

    var getListCategoriesFromLocation = function getListCategoriesFromLocation() {
      var pathnameMatches = window.location.pathname.match(/rent\/(.*?)\/?$/);
      const list_categories = pathnameMatches ? pathnameMatches[1].split("/") : [];
      const category = list_categories[0]
      const subcategory = list_categories[1]
      const children_category = list_categories[2]
      return {category: category, subcategory: subcategory, children_category: children_category}
    };

    const search = instantsearch({
      indexName: 'movri_products',
      searchClient: algoliasearch(
        algolia_application_id,
        algolia_search_only_api_key
      ),

      routing: {
        router: instantsearch.routers.history({
          createURL({ qsModule, routeState, location }) {
            const urlParts = location.href.match(/^(.*?)\/rent/);
            const baseUrl = `${urlParts ? urlParts[1] : ''}/`;
            const listCategories = getListCategoriesFromLocation()
            const categoryPath = listCategories.category
            const subcategoryPath = listCategories.subcategory

            const queryParameters = {};

            if (routeState.query) {
              queryParameters.query = encodeURIComponent(routeState.query);
            }
            if (routeState.page !== 1) {
              queryParameters.page = routeState.page;
            }
            if (routeState.brands) {
              queryParameters.brands = routeState.brands.map(encodeURIComponent);
            }

            const queryString = qsModule.stringify(queryParameters, {
              addQueryPrefix: true,
              arrayFormat: 'repeat'
            });
            if((categoryPath && subcategoryPath)){
              return `${baseUrl}rent/${categoryPath}/${subcategoryPath}`;
            } else {
              return location;
            }
          },

          parseURL({ qsModule, location }) {
            const pathnameMatches = location.pathname.match(/rent\/(.*?)\/?$/);
            const list_categories = pathnameMatches ? pathnameMatches[1].split("/") : [];

            const categories = list_categories[0]
            const subcategories = list_categories[1]
            const children_categories = list_categories[2]

            const { query = '', page} = qsModule.parse(
              location.search.slice(1)
            );
            // `qs` does not return an array when there's a single value.
            const allCategories = Array.isArray(categories)
              ? categories
              : [categories].filter(Boolean);

            const allSubcategories = Array.isArray(subcategories)
              ? subcategories
              : [subcategories].filter(Boolean);

            const allChildrenCategories = Array.isArray(children_categories)
              ? children_categories
              : [children_categories].filter(Boolean);

            return {
              query: decodeURIComponent(query),
              page,
              categories: allCategories.map(decodeURIComponent),
              subcategories: allSubcategories.map(decodeURIComponent),
              children_categories: allChildrenCategories.map(decodeURIComponent),
            };
          }
        }),

        stateMapping: {
          stateToRoute(uiState) {
            const indexUiState = uiState['movri_products'] || {};
            return {
              query: indexUiState.query,
              page: indexUiState.page,
              categories: indexUiState.refinementList && indexUiState.refinementList.category,
              subcategories: indexUiState.refinementList && indexUiState.refinementList.subcategory,
              children_categories: indexUiState.refinementList && indexUiState.refinementList.children_category,
            };
          },

          routeToState(routeState) {
            return {
              movri_products: {
                page: routeState.page,
                refinementList: {
                  category: routeState.categories,
                  subcategory: routeState.subcategories,
                  children_category: routeState.children_categories,
                }
              }
            };
          }
        }
      }
    });

    getValueOfFacets = function(exact_match){
      return exact_match ? getCategorySlug(exact_match.value) : ""
    }

    const SuggestionItemsTemplate = ({ hits }) =>`
      ${hits
        .map(
          item => {
            if(item.movri_products.facets.exact_matches){return;}

            [brand] = item.movri_products.facets.exact_matches.brand;
            [lens_type] = item.movri_products.facets.exact_matches.lens_type;
            [mount] = item.movri_products.facets.exact_matches.mount;
            return `
              <a href= ${'/categories?'+"brands="+getValueOfFacets(brand)+"&lens_types="+getValueOfFacets(lens_type)+"&mounts="+getValueOfFacets(mount)}>
                <li>
                  ${instantsearch.highlight({ attribute: 'query', hit: item })}
                </li>
              </a>`
            }
          )
        .join('')}
      `;

    const renderCurrentCategory = () => {
      list_categories = getListCategoriesFromLocation()
      children_categories_value = list_categories.children_category
      subcategories_value = list_categories.subcategory
      if(children_categories_value){
        return`${children_categories_value}`
      } else {
        return`${subcategories_value}`
      }
    }

    const renderBreadCrumbCategory = () => {
      list_categories = getListCategoriesFromLocation()
      children_categories_value = list_categories.children_category
      subcategories_value = list_categories.subcategory
      category_value = list_categories.category
      if(children_categories_value){
        return`
          <i class='fa fa-chevron-right'></i>
          <span>${category_value}</span>
          <i class='fa fa-chevron-right'></i>
          <span>${subcategories_value}</span>
          <i class='fa fa-chevron-right'></i>
          <span>${children_categories_value}</span>
        `
      } else {
        return`
          <i class='fa fa-chevron-right'></i>
          <span>${category_value}</span>
          <i class='fa fa-chevron-right'></i>
          <span>${subcategories_value}</span>
        `
      }
    }


    const renderCategoryPage = ({hits}) =>`
      <div class="snize-ac-results">
        <div class="snize-ac-results-column">
          <div class="row">
            ${hits
              .map(
                item => {
                  list_categories = getListCategoriesFromLocation()
                  children_categories_value = list_categories.children_category
                  subcategories_value = list_categories.subcategory
                  category_value = list_categories.category
                  days_rental_title = `price_rental_with_${current_duration_session}_days`
                  if(children_categories_value){
                    url_item = `/listings/${item.url}?category=${category_value}&subcategories=${subcategories_value}&children_categories=${children_categories_value}`
                  } else {
                    url_item = `/listings/${item.url}?category=${category_value}&subcategories=${subcategories_value}`
                  }

                  return`
                    <a href=${url_item}>
                      <div class="col-3">
                        <div class="listing-box">
                          <div class='main-image'>
                            <img src=${item.main_image} class="design-image-too-wide" alt="">
                          </div>
                          <div class='listing-information center-items'>
                            ${instantsearch.highlight({ attribute: 'title', hit: item })}
                          </div>
                          <div class='listing-price'>
                            <span>${item[days_rental_title]}</span>
                            <span> /${current_duration_session_label}</span>
                          </div>
                          <div>
                            <a href= ${url_item} class='rent-now-btn'>Rent Now</a>
                          </div>
                        </div>
                      </div>
                    </a>
                  `
                }
              )
            .join('')}
          </div>
        </div>
      </div>
    `;

    const renderMobileCategoryPage = ({hits}) =>`
      <div class="snize-ac-results">
        <div class="snize-ac-results-column">
          <div class="row">
            ${hits
              .map(
                item =>{
                  list_categories = getListCategoriesFromLocation()
                  children_categories_value = list_categories.children_category
                  subcategories_value = list_categories.subcategory
                  category_value = list_categories.category
                  days_rental_title = `price_rental_with_${current_duration_session}_days`
                  if(children_categories_value){
                    url_item = `/listings/${item.url}?category=${category_value}&subcategories=${subcategories_value}&children_categories=${children_categories_value}`
                  } else {
                    url_item = `/listings/${item.url}?category=${category_value}&subcategories=${subcategories_value}`
                  }
                  return`
                    <a href=${url_item}>
                      <div class="col-12">
                        <div class="listing-box-mobile">
                          <div class='main-image'>
                            <img src=${item.main_image} class="design-image-too-wide" alt=""/>
                          </div>
                          <div class='listing-information'>
                            <div class='listing-title'>
                              ${instantsearch.highlight({ attribute: 'title', hit: item })}
                            </div>
                            <div class='listing-price'>
                              <span>${item[days_rental_title]}</span>
                              <span> /${current_duration_session_label}</span>
                            </div>
                            <div class='listing-rent-now'>
                              <a href= ${url_item} class='rent-now-btn'>Rent Now</a>
                            </div>
                          </div>
                        </div>
                      </div>
                    </a>
                  `
                }
               )
            .join('')}
          </div>
        </div>
      </div>
    `;
  //============================================================================
    // Create the render function
    const createDataAttribtues = refinement =>
      Object.keys(refinement)
        .map(key => `data-${key}="${refinement[key]}"`)
        .join(' ');

    const renderListItem = item => `
      <div class='flex-items'>
        ${item.refinements
          .map(
            refinement =>{
              return`
                <span class='flex-items current-refinements-label'>
                  ${refinement.label}
                </span>
                <button ${createDataAttribtues(refinement)}>
                  <i class="fa fa-times" aria-hidden="true"></i>
                </button>
              `
            }
          )
          .join('')}
      </div>
    `;
  //============================================================================

    const renderHits = (renderOptions, isFirstRender) => {
      if (isFirstRender) {
        $('.current-category').html(renderBreadCrumbCategory);
        $('.current-collection--title').html(renderCurrentCategory);
      }
      const { hits, widgetParams } = renderOptions;
      widgetParams.container.innerHTML = renderCategoryPage({hits})
    };

    const customHits = instantsearch.connectors.connectHits(renderHits);
  //============================================================================

    const renderMobileHits = (renderOptions, isFirstRender) => {
      if (isFirstRender) {
        $('.current-category').html(renderBreadCrumbCategory);
        $('.current-collection--title').html(renderCurrentCategory);
      }
      const { hits, widgetParams } = renderOptions;
      widgetParams.container.innerHTML = renderMobileCategoryPage({hits})
    };

    const customMobileHits = instantsearch.connectors.connectHits(renderMobileHits);
  //============================================================================
    const renderCurrentRefinements = (renderOptions, isFirstRender) => {
      const { items, refine, widgetParams } = renderOptions;

      widgetParams.container.innerHTML = `
        ${items.map(renderListItem).join('')}
      `;
      Object.assign([], widgetParams.container.querySelectorAll('button')).forEach(element => {
        element.addEventListener('click', event => {
          const item = Object.keys(event.currentTarget.dataset).reduce(function (acc, key) {
            attr = key;
            value = event.currentTarget.dataset[key]
            newObj = {};
            newObj[attr] = value
            return Object.assign(acc,newObj);
          },{}
          );

          refine(item);
        });
      });
    };

    const customCurrentRefinements = instantsearch.connectors.connectCurrentRefinements(
      renderCurrentRefinements
    );
  //============================================================================
    const renderListingTypeRefinement = (renderOptions, isFirstRender) => {
      const { items, refine, widgetParams } = renderOptions;
      const container = widgetParams.container
      const header_label = widgetParams.attribute.split("_").join(" ")
      if(!items.length){
        container.innerHTML = ``
      } else{
        container.innerHTML = `
          <div class ='group-filter'>
            <ul>
              <li class='head capitalize'>${header_label}</li>
                ${items
                  .map(
                    item =>{
                      return`
                        <li>
                          <label class="ais-RefinementList-label">
                            <input type="radio" class="ais-RefinementList-checkbox" data-value='${item.value}' ${item.isRefined ? 'checked' : ''}/>
                            <span class="ais-RefinementList-labelText">${item.label.split("_").join(" ")}</span>
                          </label>
                        </li>`
                    }
                  )
                  .join('')}
            </ul>
          </div>
        `;
      }


      [...container.querySelectorAll('.ais-RefinementList-label input')].forEach(element => {
        element.addEventListener('click', event => {
          event.preventDefault();
          refine(event.currentTarget.dataset.value);
        });
      });
    };

    const customListingTypeRefinement = instantsearch.connectors.connectRefinementList(
      renderListingTypeRefinement
    );

  //============================================================================
    const renderListingTypeRefinementMobile = (renderOptions, isFirstRender) => {
      const { items, refine, widgetParams } = renderOptions;
      const container = widgetParams.container
      const header_label = widgetParams.attribute.split("_").join(" ")
      if(!items.length){
        container.innerHTML = ``

      } else {
        container.innerHTML = `
          <div class ='group-filter'>
            <ul>
              <li class='head refinementListMobile-header flex-items'>
                <div class='width-70 padding-0'>
                  <span class='capitalize'>${header_label}</span>
                </div>
                <div class='width-30 align-right'>
                  <i class="fa fa-plus" aria-hidden="true"></i>
                </div>
              </li>
              <div class='list-refinement ${items[0].isRefined ? "" : "hidden"} '>
                ${items
                  .map(
                    item => {
                      return`
                        <li>
                          <label class="ais-RefinementListMobile-label">
                            <input type="checkbox" class="ais-RefinementList-checkbox" data-value='${item.value}' ${item.isRefined ? 'checked' : ''}/>
                            <span class="capitalize ais-RefinementList-labelText">${item.label.split("_").join(" ")}</span>
                          </label>
                        </li>`
                    }
                  )
                  .join('')}
              </div>
            </ul>
          </div>
        `;
      }

      [...container.querySelectorAll('.ais-RefinementListMobile-label input')].forEach(element => {
        element.addEventListener('click', event => {
          event.preventDefault();
          refine(event.currentTarget.dataset.value);
        });
      });
    };

    const customListingTypeRefinementMobile = instantsearch.connectors.connectRefinementList(
      renderListingTypeRefinementMobile
    );
  //============================================================================


    // Create the custom widget
    if($('body').find('#item_type').length){
      search.addWidgets([
        customHits({
          container: document.querySelector('#categories-page'),

        }),

        customMobileHits({
          container: document.querySelector('#mobile-categories-page'),
        }),

        customListingTypeRefinement({
          container: document.querySelector('#item_type'),
          attribute: 'item_type',
          operator: 'and',
        }),

        customListingTypeRefinementMobile({
          container: document.querySelector('#mobile_item_type'),
          attribute: 'item_type',
          operator: 'and',
        }),


        customListingTypeRefinement({
          container: document.querySelector('#brand_refinement'),
          attribute: 'brand',
          operator: 'and',
        }),

        customListingTypeRefinement({
          container: document.querySelector('#camera_support_type_refinement'),
          attribute: 'camera_support_type',
          operator: 'and',
        }),

        customListingTypeRefinementMobile({
          container: document.querySelector('#mobile_camera_support_type_refinement'),
          attribute: 'camera_support_type',
          operator: 'and',
        }),

        customListingTypeRefinement({
          container: document.querySelector('#camcorder_type_refinement'),
          attribute: 'camcorder_type',
          operator: 'and',
        }),

        customListingTypeRefinementMobile({
          container: document.querySelector('#mobile_camcorder_type_refinement'),
          attribute: 'camcorder_type',
          operator: 'and',
        }),

        customListingTypeRefinement({
          container: document.querySelector('#sensor_size_refinement'),
          attribute: 'sensor_size',
          operator: 'and',
        }),

        customListingTypeRefinementMobile({
          container: document.querySelector('#mobile_sensor_size_refinement'),
          attribute: 'sensor_size',
          operator: 'and',
        }),

        customListingTypeRefinement({
          container: document.querySelector('#action_cam_compatibility_refinement'),
          attribute: 'action_cam_compatibility',
          operator: 'and',
        }),

        customListingTypeRefinementMobile({
          container: document.querySelector('#mobile_action_cam_compatibility_refinement'),
          attribute: 'action_cam_compatibility',
          operator: 'and',
        }),

        customListingTypeRefinement({
          container: document.querySelector('#lighting_type_refinement'),
          attribute: 'lighting_type',
          operator: 'and',
        }),

        customListingTypeRefinementMobile({
          container: document.querySelector('#mobile_lighting_type_refinement'),
          attribute: 'lighting_type',
          operator: 'and',
        }),

        customListingTypeRefinement({
          container: document.querySelector('#capacity_refinement'),
          attribute: 'capacity',
          operator: 'and',
        }),

        customListingTypeRefinementMobile({
          container: document.querySelector('#mobile_capacity_refinement'),
          attribute: 'capacity',
          operator: 'and',
        }),

        customListingTypeRefinement({
          container: document.querySelector('#memory_type_refinement'),
          attribute: 'memory_type',
          operator: 'and',
        }),

        customListingTypeRefinementMobile({
          container: document.querySelector('#mobile_memory_type_refinement'),
          attribute: 'memory_type',
          operator: 'and',
        }),

        customListingTypeRefinement({
          container: document.querySelector('#read_transfer_speed_refinement'),
          attribute: 'read_transfer_speed',
          operator: 'and',
        }),

        customListingTypeRefinementMobile({
          container: document.querySelector('#mobile_read_transfer_speed_refinement'),
          attribute: 'read_transfer_speed',
          operator: 'and',
        }),

        customListingTypeRefinement({
          container: document.querySelector('#bus_speed_refinement'),
          attribute: 'bus_speed',
          operator: 'and',
        }),

        customListingTypeRefinementMobile({
          container: document.querySelector('#mobile_bus_speed_refinement'),
          attribute: 'bus_speed',
          operator: 'and',
        }),

        customListingTypeRefinement({
          container: document.querySelector('#power_compatibility_refinement'),
          attribute: 'power_compatibility',
          operator: 'and',
        }),

        customListingTypeRefinementMobile({
          container: document.querySelector('#mobile_power_compatibility_refinement'),
          attribute: 'power_compatibility',
          operator: 'and',
        }),

        customListingTypeRefinement({
          container: document.querySelector('#power_type_refinement'),
          attribute: 'power_type',
          operator: 'and',
        }),

        customListingTypeRefinementMobile({
          container: document.querySelector('#mobile_power_type_refinement'),
          attribute: 'power_type',
          operator: 'and',
        }),

        customListingTypeRefinement({
          container: document.querySelector('#color_temperature_refinement'),
          attribute: 'color_temperature',
          operator: 'and',
        }),

        customListingTypeRefinementMobile({
          container: document.querySelector('#mobile_color_temperature_refinement'),
          attribute: 'color_temperature',
          operator: 'and',
        }),

        customListingTypeRefinement({
          container: document.querySelector('#filter_size_refinement'),
          attribute: 'filter_size',
          operator: 'and',
        }),

        customListingTypeRefinementMobile({
          container: document.querySelector('#mobile_filter_size_refinement'),
          attribute: 'filter_size',
          operator: 'and',
        }),

        customListingTypeRefinement({
          container: document.querySelector('#filter_style_refinement'),
          attribute: 'filter_style',
          operator: 'and',
        }),

        customListingTypeRefinementMobile({
          container: document.querySelector('#mobile_filter_style_refinement'),
          attribute: 'filter_style',
          operator: 'and',
        }),

        customListingTypeRefinement({
          container: document.querySelector('#filter_type_refinement'),
          attribute: 'filter_type',
          operator: 'and',
        }),

        customListingTypeRefinementMobile({
          container: document.querySelector('#mobile_filter_type_refinement'),
          attribute: 'filter_type',
          operator: 'and',
        }),

        customListingTypeRefinement({
          container: document.querySelector('#audio_type_refinement'),
          attribute: 'audio_type',
          operator: 'and',
        }),

        customListingTypeRefinementMobile({
          container: document.querySelector('#mobile_audio_type_refinement'),
          attribute: 'audio_type',
          operator: 'and',
        }),

        customListingTypeRefinement({
          container: document.querySelector('#monitoring_type_refinement'),
          attribute: 'monitoring_type',
          operator: 'and',
        }),

        customListingTypeRefinementMobile({
          container: document.querySelector('#mobile_monitoring_type_refinement'),
          attribute: 'monitoring_type',
          operator: 'and',
        }),

        customListingTypeRefinement({
          container: document.querySelector('#cable_type_refinement'),
          attribute: 'cable_type',
          operator: 'and',
        }),

        customListingTypeRefinementMobile({
          container: document.querySelector('#mobile_cable_type_refinement'),
          attribute: 'cable_type',
          operator: 'and',
        }),

        customListingTypeRefinement({
          container: document.querySelector('#camera_support_type_refinement'),
          attribute: 'camera_support_type',
          operator: 'and',
        }),

        customListingTypeRefinementMobile({
          container: document.querySelector('#mobile_camera_support_type_refinement'),
          attribute: 'camera_support_type',
          operator: 'and',
        }),

        customListingTypeRefinement({
          container: document.querySelector('#accessory_type_refinement'),
          attribute: 'accessory_type',
          operator: 'and',
        }),

        customListingTypeRefinementMobile({
          container: document.querySelector('#mobile_accessory_type_refinement'),
          attribute: 'accessory_type',
          operator: 'and',
        }),

        customListingTypeRefinement({
          container: document.querySelector('#support_type_refinement'),
          attribute: 'support_type',
          operator: 'and',
        }),

        customListingTypeRefinementMobile({
          container: document.querySelector('#mobile_support_type_refinement'),
          attribute: 'support_type',
          operator: 'and',
        }),

        customListingTypeRefinement({
          container: document.querySelector('#head_type_refinement'),
          attribute: 'head_type',
          operator: 'and',
        }),

        customListingTypeRefinementMobile({
          container: document.querySelector('#mobile_head_type_refinement'),
          attribute: 'head_type',
          operator: 'and',
        }),

        customListingTypeRefinement({
          container: document.querySelector('#quick_release_system_refinement'),
          attribute: 'quick_release_system',
          operator: 'and',
        }),

        customListingTypeRefinementMobile({
          container: document.querySelector('#mobile_quick_release_system_refinement'),
          attribute: 'quick_release_system',
          operator: 'and',
        }),

        customListingTypeRefinement({
          container: document.querySelector('#camera_type_refinement'),
          attribute: 'camera_type',
          operator: 'and',
        }),

        customListingTypeRefinementMobile({
          container: document.querySelector('#mobile_camera_type_refinement'),
          attribute: 'camera_type',
          operator: 'and',
        }),


        customListingTypeRefinement({
          container: document.querySelector('#lens-mount'),
          attribute: 'mount',
          operator: 'and',
        }),

        customListingTypeRefinementMobile({
          container: document.querySelector('#mobile_lens_mount'),
          attribute: 'mount',
          operator: 'and',
        }),


        customListingTypeRefinement({
          container: document.querySelector('#lens-type'),
          attribute: 'lens_type',
          operator: 'and',
        }),

        customListingTypeRefinementMobile({
          container: document.querySelector('#mobile_lens_type'),
          attribute: 'lens_type',
          operator: 'and',
        }),


        customListingTypeRefinement({
          container: document.querySelector('#lens-compatibility'),
          attribute: 'compatibility',
          operator: 'and',
        }),

        customListingTypeRefinement({
          container: document.querySelector('#hidden-categories'),
          attribute: 'category',
          operator: 'and',
        }),

        customListingTypeRefinement({
          container: document.querySelector('#hidden-subcategories'),
          attribute: 'subcategory',
          operator: 'and',
        }),

        customListingTypeRefinement({
          container: document.querySelector('#hidden-children-categories'),
          attribute: 'children_category',
          operator: 'and',
        }),

        customListingTypeRefinementMobile({
          container: document.querySelector('#mobile_brand_refinement'),
          attribute: 'brand',
          operator: 'and',
        }),

        customListingTypeRefinementMobile({
          container: document.querySelector('#mobile_lens_mount'),
          attribute: 'mount',
          operator: 'and',
        }),

        customListingTypeRefinementMobile({
          container: document.querySelector('#mobile_lens_type'),
          attribute: 'lens_type',
          operator: 'and',
        }),

        customListingTypeRefinementMobile({
          container: document.querySelector('#mobile_lens_compatibility'),
          attribute: 'compatibility',
          operator: 'and',
        }),

        instantsearch.widgets.searchBox({
          container: '#search-within-results',
          placeholder: 'Search within results',
          showReset: false,
          showSubmit: false,
        }),

        instantsearch.widgets.sortBy({
          container: '#sort-by',
          items: [
            { label: 'Most Popular', value: 'movri_products' },
            { label: 'Newest', value: 'sort_by_newest_products' },
            { label: 'Price: Low to High', value: 'products_price_cents_asc' },
            { label: 'Price: High to Low', value: 'products_price_cents_desc' },
          ],
        }),

        instantsearch.widgets.sortBy({
          container: '#mobile-sort-by',
          items: [
            { label: 'Most Popular', value: 'movri_products' },
            { label: 'Newest', value: 'sort_by_newest_products' },
            { label: 'Price: Low to High', value: 'products_price_cents_asc' },
            { label: 'Price: High to Low', value: 'products_price_cents_desc' },
          ],
        }),

        instantsearch.widgets.clearRefinements({
          container: '#clear-refinements',
          templates: {
            resetLabel: 'Reset',
          },
        }),

        instantsearch.widgets.pagination({
          container: '.categoties-pagination',
          padding: 2,
          scrollTo: false,
        }),

        instantsearch.widgets.pagination({
          container: '#mobile-categoties-pagination',
          padding: 1,
          scrollTo: false,
          templates: {
            previous: "Previous",
            next: "Next"
          },
           showFirst: false,
           showLast: false,
        }),

        customCurrentRefinements({
          container: document.querySelector('#current-refinements'),
          excludedAttributes: ['subcategory', 'children_category'],
        }),
      ]);
    }

    search.addWidgets([
      instantsearch.widgets.searchBox({
        container: '#category-searchbox',
      }),

      instantsearch.widgets.configure({
        hitsPerPage: 16,
        distinct: true,
        clickAnalytics: true,
      }),
    ]);

    search.start();

  };

  module.AgoliaSearchCategories = {
    initAgoliaSearchCategoties: initAgoliaSearchCategoties
  };
})(window.ST);