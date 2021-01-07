$(document).ready(function() {
  var getUrlParameter = function getUrlParameter(sParam) {
    var sPageURL = window.location.search.substring(1),
      sURLVariables = sPageURL.split('&'),
      sParameterName,
      i;

    for (i = 0; i < sURLVariables.length; i++) {
      sParameterName = sURLVariables[i].split('=');

      if (sParameterName[0] === sParam) {
        return sParameterName[1] === undefined ? true : decodeURIComponent(sParameterName[1]);
      }
    }
  };

  const search = instantsearch({
    indexName: 'movri_products',
    searchClient: algoliasearch(
      algolia_application_id,
      algolia_search_only_api_key
    ),
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

  function update_link_search_result(count, query){
    $(".view-all-products").html(`<a href='/search-results-page/?query=${query}'>View all ${count} items</a>`)
  }

  const ProductItemsTemplate = ( { hits } ) => {
    return `
    ${hits
      .map(
        item =>
          {
            days_rental_title = `price_rental_with_${current_duration_session}_days`
            return`
              <div class="desktop-display">
                <li>
                  <a href= ${'/listings/'+ item.url}>
                    <div class='flex-items'>
                      <div class='width-10 center-items'>
                        <img src=${item.main_image} class="design-image-too-wide width-100" alt="">
                      </div>
                      <div class='width-90'>
                        <span class='block'>${instantsearch.highlight({ attribute: 'title', hit: item })}</span>
                        <span class='sku block'>SKU: ${item.sku}</span>
                        <div class='listing-price'>
                          <span>${item[days_rental_title]}</span>
                          <span> /${current_duration_session_label}</span>
                        </div>
                      </div>
                    </div>
                  </a>
                </li>
              </div>
              <div class="mobile-display">
                <li>
                  <a href= ${'/listings/'+ item.url}>
                    <div class='flex-items'>
                      <div class='width-30 center-items'>
                        <img src=${item.main_image} class="design-image-too-wide search-moobile-image" alt="">
                      </div>
                      <div class='width-70'>
                        <span class='block'>${instantsearch.highlight({ attribute: 'title', hit: item })}</span>
                        <span class='sku block'>SKU: ${item.sku}</span>
                        <div class='listing-price'>
                          <span>${item[days_rental_title]}</span>
                          <span> /${current_duration_session_label}</span>
                        </div>
                      </div>
                    </div>
                  </a>
                </li>
              </div>
            `
          }
        )
      .join('')}
    `;
  };

  // const renderSuggestionCategories = ({hits}) => {
  //   hits = hits.slice(0, 3)
  //   return `
  //   ${hits
  //     .map(
  //       item =>
  //         {
  //           category = item.category;
  //           return`
  //             <div class='padding-5'>
  //               <div class='bold fz-18'>
  //                 <a class='capitalize' href= ${'/categories?'+"categories="+getCategorySlug(category)}>${category}</>
  //               </div>
  //             </div>
  //           `
  //         }
  //       )
  //     .join('')}
  //   `;
  // }

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
  const renderProductItems = (renderOptions, isFirstRender) => {
    if (isFirstRender) {}
    const container = document.querySelector('.search-result-algolia');
    const {currentRefinement, indices } = renderOptions;
    if(indices[0]){
      update_link_search_result(indices[0].hits.length, currentRefinement)
      $('.product-items').html([indices[0]].map(ProductItemsTemplate).join(''));
      // $('#suggestion-categories').html([indices[0]].map(renderSuggestionCategories).join(''));
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
  const renderStats = (renderOptions, isFirstRender) => {
    const { nbHits, processingTimeMS, query, widgetParams } = renderOptions;

    if (isFirstRender) {
      return;
    }

    let count = '';
    if (nbHits > 1) {
      count += `${nbHits} results`;
    } else if (nbHits === 1) {
      count += `1 item`;
    } else {
      count += `no result`;
    }

    widgetParams.container.innerHTML = `
      <a href='/search-results-page/?query=${query}'>View all ${count}</a>
    `;
  };

  const customStats = instantsearch.connectors.connectStats(renderStats);

//============================================================================
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
      hitsPerPage: 3,
      distinct: true,
      clickAnalytics: true,
    }),

    customStats({
      container: document.querySelector('.view-all-products'),
    }),

    // instantsearch.widgets
    //   .index({ indexName: 'movri_products_query_suggestions' })
    //   .addWidgets([
    //     customAutocomplete({
    //       container: $('.suggestion-items'),
    //     }),
    //     instantsearch.widgets.configure({
    //       distinct: true,
    //       clickAnalytics: true,
    //     }),
    //   ]),
  ]);

  search.start();

  $(document).click (function (e) {
    var search_result = $('.search-result-algolia');
    if (e.target == $('.searchbox-algolia input')[0] ||
      e.target == $('.searchbox-algolia input')[1] ||
      $(e.target).parents('.search-result-algolia')[0] == $('.search-result-algolia')[0]) {
      $(search_result).show();
    } else {
      $(search_result).hide();
    }
  });

});