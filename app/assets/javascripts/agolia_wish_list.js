window.ST = window.ST || {};

(function(module) {
  var initAgoliaWishListResult = function(current_user_id) {
  // ====================================================================================
    const search = instantsearch({
      indexName: 'movri_products',
      searchClient: algoliasearch(
        algolia_application_id,
        algolia_search_only_api_key
      ),
      routing: {
        stateMapping: {
          routeToState(routeState) {
            return {
              movri_products: {
                query: routeState.query,
                page: routeState.page,
                refinementList: {
                  wisher_id: [current_user_id]
                },
              },
            };
          },
          stateToRoute(uiState) {
            return {
              query:
                uiState && uiState.movri_products && uiState.movri_products.query,
              page:
                uiState && uiState.movri_products && uiState.movri_products.page,
            };
          },
        },
      },
    });
  // ====================================================================================
    const renderWishList = ({hits}) =>`
      <div class="snize-ac-results">
        <div class="snize-ac-results-column">
          ${hits
            .map(
              item => {
                days_rental_title = `price_rental_with_${current_duration_session}_days`
                return`
                  <div class='flex-items padding-15 br-bottom wish-list-item'>
                    <div class='width-15 margin-0'>
                      <a href= ${'/listings/'+ item.url}>
                        <div class='main-image'>
                          <img src=${item.main_image} class="design-image-too-wide width-100">
                        </div>
                      </a>
                    </div>
                    <div class='width-35 center-items'>
                      <a href= ${'/listings/'+ item.url}>
                        ${item.title}
                      </a>
                    </div>
                    <div class='width-20 center-items'>
                      <div class='wish-list-listing-price'>
                        <span>${item[days_rental_title]}</span>
                        <span> / ${current_duration_session} Days Rental</span>
                      </div>
                    </div>
                    <div class='width-20 center-items'>
                      <i class="fa fa-trash-o wish-list-remove-icon"  data-id='${item.id}' aria-hidden="true"></i>
                    </div>
                    <div class='width-20'>
                      <div class="btn add-wish-list-to-cart" data-id='${item.id}'>
                        <span>Add to cart</span>
                      </div>
                    </div>
                  </div>
                `
              }
            )
          .join('')}
        </div>
      </div>
    `;

    const renderMobileWishListPage = ({hits}) =>`
      <div class="snize-ac-results">
        <div class="snize-ac-results-column">
          <div class="row">
            ${hits
              .map(
                item =>{
                  days_rental_title = `price_rental_with_${current_duration_session}_days`
                  return`
                    <div class='col-6 padding-l-r-15 wish-list-item'>
                      <div class='mobile-listing-box'>
                        <i class="fa fa-times-circle-o wish-list-remove-icon" data-id='${item.id}' aria-hidden="true"></i>
                        <a href= ${'/listings/'+ item.url}>
                          <div class='main-image'>
                            <img src=${item.main_image} class="design-image-too-wide" alt=""/>
                          </div>
                        </a>
                        <a href= ${'/listings/'+ item.url}>
                          <div class='listing-information center-items'>
                            ${item.title}
                          </div>
                        </a>
                        <div class='listing-price br-bottom'>
                          <span>${item[days_rental_title]}</span>
                          <span> /${current_duration_session} days</span>
                        </div>
                        <div class="center-items margin-t-10 add-wish-list-to-cart" data-id='${item.id}'>
                          <span>Add to cart</span>
                        </div>
                      </div>
                    </div>
                  `
                }
               )
            .join('')}
          </div>
        </div>
      </div>
    `;

    const renderHits = (renderOptions, isFirstRender) => {
      if (isFirstRender) {}
      const { results, hits, widgetParams } = renderOptions;
      widgetParams.container.innerHTML = renderWishList({hits})
    };

    const customHits = instantsearch.connectors.connectHits(renderHits);

  // ====================================================================================
    const renderMobileHits = (renderOptions, isFirstRender) => {
      if (isFirstRender) {
      }
      const { hits, widgetParams } = renderOptions;
      widgetParams.container.innerHTML = renderMobileWishListPage({hits})
    };

    const customMobileHits = instantsearch.connectors.connectHits(renderMobileHits);

  // ====================================================================================
    search.addWidgets([
      instantsearch.widgets.searchBox({
        container: '#wish-list-searchbox',
        placeholder: 'Search your Wish Lists',
        showSubmit: false,
        showReset: false,
      }),

      customHits({
        container: document.querySelector('.wish-list-result'),
      }),

      instantsearch.widgets.refinementList({
        container: '#wisher-id',
        attribute: 'wisher_id',
        operator: 'or',
      }),

      instantsearch.widgets.pagination({
        padding: 2,
        container: '.wish-list-pagination',
        scrollTo: false,
      }),

      customMobileHits({
        container: document.querySelector('.mobile-wish-list-result'),
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

      instantsearch.widgets.configure({
        hitsPerPage: 16,
        distinct: true,
        clickAnalytics: true,
      }),
    ]);

    search.start();

  };

  module.AgoliaWishListResult = {
    initAgoliaWishListResult: initAgoliaWishListResult
  };
})(window.ST);