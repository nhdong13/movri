$(document).ready(function() {

  function getCategorySlug(name) {
    return name
      .split(' ')
      .map(encodeURIComponent)
      .join('+');
  }

  function getCategoryName(slug) {
    return slug
      .split('+')
      .map(decodeURIComponent)
      .join(' ');
  }

  const search = instantsearch({
    indexName: 'movri_products',
    searchClient: algoliasearch(
      algolia_application_id,
      algolia_search_only_api_key
    ),

    routing: {
      router: instantsearch.routers.history({
        windowTitle({ category, query }) {
          const queryTitle = query ? `Results for "${query}"` : 'Search';

          if (category) {
            return `${category} – ${queryTitle}`;
          }

          return queryTitle;
        },

        createURL({ qsModule, routeState, location }) {
          const urlParts = location.href.match(/^(.*?)\/categories/);
          const baseUrl = `${urlParts ? urlParts[1] : ''}/`;
          const categoryPath = routeState.category
            ? `${getCategorySlug(routeState.category)}/`
            : '';
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

          return `${baseUrl}categories${categoryPath}${queryString}`;
        },

        parseURL({ qsModule, location }) {
          const pathnameMatches = location.pathname.match(/categories\/(.*?)\/?$/);
          const category = getCategoryName(
            (pathnameMatches && pathnameMatches[1]) || ''
          );
          const { query = '', page, brands, mounts, lens_types, categories, subcategories, children_categories = [] } = qsModule.parse(
            location.search.slice(1)
          );
          // `qs` does not return an array when there's a single value.
          const allBrands = Array.isArray(brands)
            ? brands
            : [brands].filter(Boolean);

          const allMounts = Array.isArray(mounts)
            ? mounts
            : [mounts].filter(Boolean);

          const allLensTypes = Array.isArray(lens_types)
            ? lens_types
            : [lens_types].filter(Boolean);

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
            brands: allBrands.map(decodeURIComponent),
            mounts: allMounts.map(decodeURIComponent),
            lens_types: allLensTypes.map(decodeURIComponent),
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
            brands: indexUiState.refinementList && indexUiState.refinementList.brand,
            mounts: indexUiState.refinementList && indexUiState.refinementList.mount,
            lens_types: indexUiState.refinementList && indexUiState.refinementList.lens_type,
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
                brand: routeState.brands,
                mount: routeState.mounts,
                lens_type: routeState.lens_types,
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

  const ProductItemsTemplate = ( { hits } ) => {
    hits = hits.slice(0, 3)
    return `
    ${hits
      .map(
        item =>`
          <li>
            <a href= ${'/listings/'+ item.id}>
              <div class='flex-items'>
                <div class='width-10 center-items'>
                  <img src=${item.main_image} class="design-image-too-wide width-100" alt="">
                </div>
                <div class='width-90'>
                  <span class='block'>${instantsearch.highlight({ attribute: 'title', hit: item })}</span>
                  <span class='sku block'>SKU: ${item.sku}</span>
                  <div class='listing-price'>
                    <span>${item.default_7_days_rental_price}</span>
                    <span>/ 7 days</span>
                  </div>
                </div>
              </div>
            </a>
          </li>
        `)
      .join('')}
    `;
  };

  const renderSuggestionCategories = ({hits}) => {
    hits = hits.slice(0, 3)
    return `
    ${hits
      .map(
        item =>
          {
            category = item.category;
            return`
              <div class='padding-5'>
                <div class='bold fz-18'>
                  <a class='capitalize' href= ${'/categories?'+"categories="+getCategorySlug(category)}>${category}</>
                </div>
              </div>
            `
          }
        )
      .join('')}
    `;
  }

  const renderCurrentCategory = ({hits}) => {
    hits = hits.slice(0, 1)
    return `
    ${hits
      .map(
        item =>
          {
            category = item.category;
            subcategory = item.subcategory;
            children_category = item.children_category;
            if(children_category){
              return`${children_category}`
            } else {
              return`${subcategory}`
            }
          }
        )
      .join('')}
    `;
  }

  const renderBreadCrumbCategory = ({hits}) => {
    hits = hits.slice(0, 1)
    return `
    ${hits
      .map(
        item =>
          {
            category = item.category;
            subcategory = item.subcategory;
            children_category = item.children_category;
            if(children_category){
              return`
                <i class='fa fa-chevron-right'></i>
                <span>${category}</span>
                <i class='fa fa-chevron-right'></i>
                <span>${subcategory}</span>
                <i class='fa fa-chevron-right'></i>
                <span>${children_category}</span>
              `
            }else{
              return`
                <i class='fa fa-chevron-right'></i>
                <span>${category}</span>
                <i class='fa fa-chevron-right'></i>
                <span>${subcategory}</span>
              `
            }
          }
        )
      .join('')}
    `;
  }


  const renderCategoryPage = ({hits}) =>`
    <div class="snize-ac-results">
      <div class="snize-ac-results-column">
        <div class="row">
          ${hits
            .map(
              item =>
                `<a href= ${'/listings/'+ item.id}>
                  <div class="col-3">
                    <div class="listing-box">
                      <div class='main-image'>
                        <img src=${item.main_image} class="design-image-too-wide" alt="">
                      </div>
                      <div class='listing-information center-items'>
                        ${instantsearch.highlight({ attribute: 'title', hit: item })}
                      </div>
                      <div class='listing-price'>
                        <span>${item.default_7_days_rental_price}</span>
                        <span> /7 day</span>
                      </div>
                      <div>
                        <a href= ${'/listings/'+ item.id} class='rent-now-btn'>Rent Now</a>
                      </div>
                    </div>
                  </div>
                </a>`
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
              item =>
                `<a href= ${'/listings/'+ item.id}>
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
                          <span>${item.default_7_days_rental_price}</span>
                          <span> /7 day</span>
                        </div>
                        <div class='listing-rent-now'>
                          <a href= ${'/listings/'+ item.id} class='rent-now-btn'>Rent Now</a>
                        </div>
                      </div>
                    </div>
                  </div>
                </a>`
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

  const renderSuggestionItems = (renderOptions, isFirstRender) => {
    const { indices, currentRefinement, refine } = renderOptions;
    const container = document.querySelector('.search-result-algolia');
    const inputs = $('.searchbox-algolia input');
    if (isFirstRender) {
      _.map(inputs, function(input){
        input.addEventListener('input', event => {
          refine(event.currentTarget.value);
        });
      })
    }
    $('.suggestion-items').html(indices.map(SuggestionItemsTemplate).join(''));
  };

  const customAutocomplete = instantsearch.connectors.connectAutocomplete(
    renderSuggestionItems
  );
//============================================================================

  const renderHits = (renderOptions, isFirstRender) => {
    if (isFirstRender) {
    }
    const { hits, widgetParams } = renderOptions;
    widgetParams.container.innerHTML = renderCategoryPage({hits})
  };

  const customHits = instantsearch.connectors.connectHits(renderHits);
//============================================================================

  const renderMobileHits = (renderOptions, isFirstRender) => {
    if (isFirstRender) {
    }
    const { hits, widgetParams } = renderOptions;
    widgetParams.container.innerHTML = renderMobileCategoryPage({hits})
  };

  const customMobileHits = instantsearch.connectors.connectHits(renderMobileHits);
//============================================================================

  const renderProductItems = (renderOptions, isFirstRender) => {
    if (isFirstRender) {}
    const container = document.querySelector('.search-result-algolia');
    const { indices } = renderOptions;
    if(indices[0]){
      $('.product-items').html([indices[0]].map(ProductItemsTemplate).join(''));
      $('#suggestion-categories').html([indices[0]].map(renderSuggestionCategories).join(''));
      $('.current-category').html([indices[0]].map(renderBreadCrumbCategory).join(''));
      $('.current-collection--title').html([indices[0]].map(renderCurrentCategory).join(''));
    }
  };

  const searchProductsResult = instantsearch.connectors.connectAutocomplete(
    renderProductItems
  );
//============================================================================
  const renderSearchBox = (renderOptions, isFirstRender) => {
    const { query, refine } = renderOptions;
    const container = $(".searchbox-algolia")
    if (isFirstRender) {
      _.map(container, function(item){
        const input = document.createElement('input');

        input.addEventListener('input', event => {
          refine(event.currentTarget.value);
        });

        item.appendChild(input);
      })
    }
  };

  const customSearchBox = instantsearch.connectors.connectSearchBox(
    renderSearchBox
  );
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
        totalPages: 2,
        scrollTo: false,
      }),

      instantsearch.widgets.pagination({
        container: '#mobile-categoties-pagination',
        totalPages: 2,
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
    customSearchBox({
      container: document.querySelector('.searchbox-algolia'),
      placeholder: 'Search for products',
      showSubmit: false,
      showReset: false,
    }),

    searchProductsResult({
      container: document.querySelector('.search-result-algolia'),
    }),

    instantsearch.widgets.configure({
      hitsPerPage: 16,
      distinct: true,
      clickAnalytics: true,
    }),

    instantsearch.widgets
      .index({ indexName: 'movri_products_query_suggestions' })
      .addWidgets([
        customAutocomplete({
          container: $('.suggestion-items'),
        }),
        instantsearch.widgets.configure({
          hitsPerPage: 3,
          distinct: true,
          clickAnalytics: true,
        }),
      ]),
  ]);

  search.start();

  $(document).click (function (e) {
    var search_result = $('.search-result-algolia');
    if (e.target == $('.searchbox-algolia input')[0] ||
      e.target == $('.searchbox-algolia input')[1] ||
      $(e.target).parents('.search-result-algolia')[0] == $('.search-result-algolia')[0]||
      $(e.target).parents('.search-mobile-icon')[0] == $('.search-mobile-icon')[0]) {
      $(search_result).show();
    } else {
      $('.mobile-display .searchbox-algolia input').hide()
      $(search_result).hide();
    }
  });

});