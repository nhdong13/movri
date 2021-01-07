window.ST = window.ST || {};

(function(module) {
  var initAgoliaSearchResult = function() {
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
  // ====================================================================================
    const renderCategoryPage = ({hits}) =>`
      <div class="snize-ac-results">
        <div class="snize-ac-results-column">
          <div class="row">
            ${hits
              .map(
                item => {
                  days_rental_title = `price_rental_with_${current_duration_session}_days`
                  return`
                    <a href= ${'/listings/'+ item.url}>
                      <div class="col-3">
                        <div class="listing-box">
                          <div class='main-image'>
                            <img src=${item.main_image} class="design-image-too-wide" alt="">
                          </div>
                          <div class='listing-information center-items'>
                            ${item.title}
                          </div>
                          <div class='listing-price'>
                            <span>${item[days_rental_title]}</span>
                            <span> /${current_duration_session_label}</span>
                          </div>
                          <div>
                            <a href= ${'/listings/'+ item.url} class='rent-now-btn'>Rent Now</a>
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
                  days_rental_title = `price_rental_with_${current_duration_session}_days`
                  return`
                    <a href= ${'/listings/'+ item.url}>
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
                              <a href= ${'/listings/'+ item.url} class='rent-now-btn'>Rent Now</a>
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

    const renderHits = (renderOptions, isFirstRender) => {
      if (isFirstRender) {}
      const { results, hits, widgetParams } = renderOptions;
      widgetParams.container.innerHTML = renderCategoryPage({hits})
    };

    const customHits = instantsearch.connectors.connectHits(renderHits);

  // ====================================================================================
    const renderMobileHits = (renderOptions, isFirstRender) => {
      if (isFirstRender) {
      }
      const { hits, widgetParams } = renderOptions;
      widgetParams.container.innerHTML = renderMobileCategoryPage({hits})
    };

    const customMobileHits = instantsearch.connectors.connectHits(renderMobileHits);

  // ====================================================================================
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
        Showing <strong>${count}</strong> for "${query}"
      `;
    };

    const customStats = instantsearch.connectors.connectStats(renderStats);
  //============================================================================

    search.addWidgets([
      instantsearch.widgets.searchBox({
        container: '#searchbox',
      }),

      customHits({
        container: document.querySelector('.search-result-listings'),
      }),

      customMobileHits({
        container: document.querySelector('.mobile-search-result-listings'),
      }),

      instantsearch.widgets.pagination({
        padding: 2,
        container: '.categoties-pagination',
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

      customStats({
        container: document.querySelector('.search-result-header'),
      }),

      instantsearch.widgets.configure({
        hitsPerPage: 16,
        distinct: true,
        clickAnalytics: true,
      }),
    ]);

    search.start();

  };

  module.AgoliaSearchResult = {
    initAgoliaSearchResult: initAgoliaSearchResult
  };
})(window.ST);