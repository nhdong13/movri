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
      'IIXUYFGM4K',
      '304da7c0dd54da7a5ca0c191243a3ced'
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
                  ${instantsearch.highlight({ attribute: 'title', hit: item })}
                </div>
              </div>
            </a>
          </li>
        `)
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
                    <a href= ${'/listings/'+ item.id} class='rent-now-btn'>Rent now</a>
                  </div>
                </div>`
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
                `<div class="col-12">
                  <div class="listing-box-mobile">
                    <div class='main-image'>
                      <img src=${item.main_image} class="design-image-too-wide" alt="">
                    </div>
                    <div class='listing-information'>
                      <div class='listing-title cut-text'>
                        ${instantsearch.highlight({ attribute: 'title', hit: item })}
                      </div>
                      <div class='listing-price'>
                        <span>${item.price_cents}</span>
                        <span> /1 day</span>
                      </div>
                      <div class='listing-rent-now'>
                        <a href= ${'/listings/'+ item.id} class='rent-now-btn'>Rent now</a>
                      </div>
                    </div>
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

    $('.product-items').html(indices.map(ProductItemsTemplate).join(''));
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

  // Create the custom widget
  if($('body').find('#refinement-list').length){
    search.addWidgets([
      customHits({
        container: document.querySelector('#categories-page'),
      }),

      customMobileHits({
        container: document.querySelector('#mobile-categories-page'),
      }),

      instantsearch.widgets.refinementList({
        container: '#refinement-list',
        attribute: 'brand',
        operator: 'or',
      }),

      instantsearch.widgets.refinementList({
        container: '#mobile-refinement-list',
        attribute: 'brand',
        operator: 'or',
      }),

      instantsearch.widgets.refinementList({
        container: '#lens-mount',
        attribute: 'mount',
        operator: 'or',
      }),

      instantsearch.widgets.refinementList({
        container: '#mobile-lens-mount',
        attribute: 'mount',
        operator: 'or',
      }),

      instantsearch.widgets.refinementList({
        container: '#lens-type',
        attribute: 'lens_type',
        operator: 'or',
      }),

      instantsearch.widgets.refinementList({
        container: '#mobile-lens-type',
        attribute: 'lens_type',
        operator: 'or',
      }),

      instantsearch.widgets.refinementList({
        container: '#lens-compatibility',
        attribute: 'compatibility',
        operator: 'or',
      }),

      instantsearch.widgets.refinementList({
        container: '#lens-compatibility',
        attribute: 'compatibility',
        operator: 'or',
      }),

      instantsearch.widgets.refinementList({
        container: '#hidden-categories',
        attribute: 'category',
        operator: 'or',
      }),

      instantsearch.widgets.refinementList({
        container: '#hidden-subcategories',
        attribute: 'subcategory',
        operator: 'or',
      }),

      instantsearch.widgets.refinementList({
        container: '#hidden-children-categories',
        attribute: 'children_category',
        operator: 'or',
      }),

      instantsearch.widgets.refinementList({
        container: '#mobile-lens-compatibility',
        attribute: 'compatibility',
        operator: 'or',
      }),

      instantsearch.widgets.sortBy({
        container: '#sort-by',
        items: [
          { label: 'Sort', value: 'movri_products' },
          { label: 'Most Popular', value: 'most_popular_products' },
          { label: 'Newest', value: 'sort_by_newest_products' },
          { label: 'Price: Low to High', value: 'products_price_cents_asc' },
          { label: 'Price: High to Low', value: 'products_price_cents_desc' },
        ],
      }),

      instantsearch.widgets.sortBy({
        container: '#mobile-sort-by',
        items: [
          { label: 'Sort By', value: 'movri_products' },
          { label: 'Most Popular', value: 'most_popular_products' },
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
      })
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

  $(document).click (function (e) {
    if($('.mobile-listing-filter').is(":visible")){
      if($(e.target).parents('.mobile-listing-filter')[0] == $('.mobile-listing-filter')[0] ||
        e.target == $('.sort-filter-bar #filter')[0]){
        $('.mobile-listing-filter').show();
      } else {
        $('.mobile-listing-filter').hide();
        e.preventDefault();
      }
    }
  });
});