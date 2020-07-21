$(document).ready(function() {
  const search = instantsearch({
    indexName: 'Listing',
    searchClient: algoliasearch(
      'I9M2XD27BV',
      '30b73223325eca9f17cfbe9fea6a9775'
    ),
  });

  const currentSearchValue = function (){
    current_location = window.location.href;
    params = current_location.split("?")[1];
    if(params){
      return search_query = current_location.split("?")[1].split("=")[1]
    }
  }

  const SuggestionItemsTemplate = ({ hits }) => `
    ${hits
      .map(
        item =>`
          <li>${instantsearch.highlight({ attribute: 'query', hit: item })}</li>
        `)
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
    const input = $('#searchbox input')[0];
    if (isFirstRender) {
      if(currentSearchValue()){
        input.value = currentSearchValue();
        refine(event.currentTarget.value);
      }
      input.addEventListener('input', event => {
        refine(event.currentTarget.value);
      });
    }

    input.value = currentRefinement;
    container.querySelector('#suggestion-items').innerHTML = indices
      .map(SuggestionItemsTemplate)
      .join('');
  };

  const customAutocomplete = instantsearch.connectors.connectAutocomplete(
    renderSuggestionItems
  );
//============================================================================

  const renderHits = (renderOptions, isFirstRender) => {
    if (isFirstRender) {
      $('#hits').hide()
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
    container.querySelector('#product-items').innerHTML = indices
      .map(ProductItemsTemplate)
      .join('');
  };

  const searchProductsResult = instantsearch.connectors.connectAutocomplete(
    renderProductItems
  );
//============================================================================
  const renderSearchBox = (renderOptions, isFirstRender) => {
    const { query, refine } = renderOptions;

    const container = document.querySelector('#searchbox');

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
          container: $('#suggestion-items'),
          onSelectChange({ query }) {
            search.helper.setQuery(query).search();
          },
        }),
      ]),
  ]);

  search.start();

  $(document).keypress(function(event){
    var keycode = (event.keyCode ? event.keyCode : event.which);
    if(keycode == '13'){
      if ($('.header-search-input').is(':focus')) {
      };
    }
  });

  $(document).click (function (e) {
    var search_result = $('#search-result');
    if (e.target == $('#searchbox input')[0] || $(e.target).parents('#search-result')[0] == $('#search-result')[0]) {
      $(search_result).show();
    } else {
      $(search_result).hide();
    }
  });
});