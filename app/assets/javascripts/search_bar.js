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
    indexName: 'Listing',
    searchClient: algoliasearch(
      'I9M2XD27BV',
      '30b73223325eca9f17cfbe9fea6a9775'
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
          const { query = '', page, brands, mounts, lens_types = [] } = qsModule.parse(
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

          return {
            query: decodeURIComponent(query),
            page,
            brands: allBrands.map(decodeURIComponent),
            mounts: allMounts.map(decodeURIComponent),
            lens_types: allLensTypes.map(decodeURIComponent),
          };
        }
      }),

      stateMapping: {
        stateToRoute(uiState) {
          const indexUiState = uiState['Listing'] || {};

          return {
            query: indexUiState.query,
            page: indexUiState.page,
            brands: indexUiState.refinementList && indexUiState.refinementList.brand,
            mounts: indexUiState.refinementList && indexUiState.refinementList.mount,
            lens_type: indexUiState.refinementList && indexUiState.refinementList.lens_type,
          };
        },

        routeToState(routeState) {
          return {
            Listing_query_suggestions_v4: {query: routeState.query},
            Listing: {
              page: routeState.page,
              refinementList: {
                brand: routeState.brands,
                mount: routeState.mounts,
                lens_type: routeState.lens_types,
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
          [brand] = item.Listing.facets.exact_matches.brand;
          [lens_type] = item.Listing.facets.exact_matches.lens_type;
          [mount] = item.Listing.facets.exact_matches.mount;
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

  const ProductItemsTemplate = ( { hits } ) => `
    ${hits
      .map(
        item =>`
          <li>
            <a href= ${'/listings/'+ item.objectID}>
              <div class='flex-items'>
                <div class='width-20 center-items'>
                  <img src=${item.main_image} class="design-image-too-wide width-100" alt="">
                </div>
                <div class='width-80'>
                  ${instantsearch.highlight({ attribute: 'title', hit: item })}
                </div>
              </div>
            </a>
          </li>
        `)
      .join('')}
    `;

  const renderCategoryPage = ({hits}) =>`
    <div class="snize-ac-results">
      <div class="snize-ac-results-column">
        <div class="row">
          ${hits
            .map(
              item =>
                `<div class="col-3">
                  <div class="listing-box">
                    <div class='main-image'>
                      <img src=${item.main_image} class="design-image-too-wide" alt="">
                    </div>
                    <div class='listing-price'>
                      <span>${item.price_cents}</span>
                      <span> /1 day</span>
                    </div>
                    <div class='listing-information'>
                      ${instantsearch.highlight({ attribute: 'title', hit: item })}
                    </div>
                    <a href= ${'/listings/'+ item.objectID} class='rent-now-btn'>Rent now</a>
                  </div>
                </div>`
              )
          .join('')}
        </div>
      </div>
    </div>
  `;

//============================================================================

  const renderSuggestionItems = (renderOptions, isFirstRender) => {
    const { indices, currentRefinement, refine } = renderOptions;
    const container = document.querySelector('#search-result');
    const input = $('.searchbox-algolia input')[0];
    if (isFirstRender) {
      input.addEventListener('input', event => {
        refine(event.currentTarget.value);
      });
    }
    if(currentRefinement.length){
      input.value = currentRefinement;
    }
    container.querySelector('.suggestion-items').innerHTML = indices
      .map(SuggestionItemsTemplate)
      .join('');
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

  const renderProductItems = (renderOptions, isFirstRender) => {
    if (isFirstRender) {
     $('#search-result').hide()
    }
    const container = document.querySelector('#search-result');
    const { indices } = renderOptions;
    container.querySelector('.product-items').innerHTML = indices
      .map(ProductItemsTemplate)
      .join('');
  };

  const searchProductsResult = instantsearch.connectors.connectAutocomplete(
    renderProductItems
  );
//============================================================================
  const renderSearchBox = (renderOptions, isFirstRender) => {
    const { query, refine } = renderOptions;

    const container = document.querySelector('.searchbox-algolia');
    if (isFirstRender) {
      const input = document.createElement('input');

      input.addEventListener('input', event => {
        refine(event.currentTarget.value);
      });

      container.appendChild(input);

    }
    container.querySelector('input').value = query;
  };

  const customSearchBox = instantsearch.connectors.connectSearchBox(
    renderSearchBox
  );
//============================================================================

  // Create the custom widget
  if($('body').find('#refinement-list').length){
    search.addWidgets([
      customHits({
        container: document.querySelector('#categories-page'),
      }),

      instantsearch.widgets.refinementList({
        container: '#refinement-list',
        attribute: 'brand',
        operator: 'or',
      }),

      instantsearch.widgets.refinementList({
        container: '#lens-mount',
        attribute: 'mount',
        operator: 'or',
      }),

      instantsearch.widgets.refinementList({
        container: '#lens-type',
        attribute: 'lens_type',
        operator: 'or',
      }),

      instantsearch.widgets.refinementList({
        container: '#lens-compatibility',
        attribute: 'compatibility',
        operator: 'or',
      }),

      instantsearch.widgets.sortBy({
        container: '#sort-by',
        items: [
          { label: 'Most Popular', value: 'most_popular_listing' },
          { label: 'Newest', value: 'sort_by_newest' },
          { label: 'Price: Low to High', value: 'price_cents_asc' },
          { label: 'Price: High to Low', value: 'price_cents_desc' },
        ],
      })
    ]);
  }

  search.addWidgets([
    customSearchBox({
      placeholder: 'Search for products',
      showSubmit: false,
      showReset: false,
    }),

    searchProductsResult({
      container: document.querySelector('#search-result'),
    }),

    instantsearch.widgets.configure({
      hitsPerPage: 3,
      distinct: true,
      clickAnalytics: true,
    }),

    instantsearch.widgets
      .index({ indexName: 'Listing_query_suggestions_v4' })
      .addWidgets([
        customAutocomplete({
          container: $('.suggestion-items'),
        }),
      ]),
  ]);

  search.start();

  $(document).click (function (e) {
    var search_result = $('#search-result');
    if (e.target == $('.searchbox-algolia input')[0] || $(e.target).parents('#search-result')[0] == $('#search-result')[0]) {
      $(search_result).show();
    } else {
      $(search_result).hide();
    }
  });
});