window.ST = window.ST || {};

(function(module) {
  var initSearchPromoCodes = function() {
    const search = instantsearch({
      indexName: 'movri_promo_codes',
      searchClient: algoliasearch(
        algolia_application_id,
        algolia_search_only_api_key
      ),
    });

  // ====================================================================================
    const renderPromoCodesPage = ( { hits } ) => {
      return `
      ${hits
        .map(
          item =>`
            <li>
              <div class='flex-items br-bottom padding-15'>
                <div class='width-40'>
                  <span class='block'>${item.code}</span>
                  <span class='items-style'>${item.desc}</span>
                </div>
                <div class='width-20 center-items margin-0'>
                  <div class='common-label-btn common-admin-btn'>
                    <a href="/en/admin/promo_codes/${item.id}/edit">Edit</a>
                  </div>
                  <div class='common-label-btn common-admin-delete-btn margin-0'>
                    <a data-confirm="Are you sure?" data-method="delete" href="/en/admin/promo_codes/${item.id}/">Delete</a>
                  </div>
                </div>
                <div class='width-10 center-items'>
                  <span class='${item.active=='Active' ? 'active' : 'expired'}-label'>${item.active=='Active' ? 'Active' : 'Expired'}</span>
                </div>
                <div class='width-10 center-items'>
                  <span class='items-style'>${item.number_of_uses} used</span>
                </div>
                <div class='width-20 center-items'>
                  <span>${item.start_datetime} - ${item.end_datetime}</span>
                </div>
              </div>
            </li>
          `)
        .join('')}
      `;
    };

    const renderPromoCodesItems = (renderOptions, isFirstRender) => {
      if (isFirstRender) {}
      const { hits, widgetParams } = renderOptions;
      widgetParams.container.innerHTML = renderPromoCodesPage({hits})
    };

    const searchPromoCodesResult = instantsearch.connectors.connectHits(renderPromoCodesItems)
  // ====================================================================================

    search.addWidgets([
      instantsearch.widgets.searchBox({
        container: '.search-promo-codes',
        placeholder: 'Search for promo codes',
        showSubmit: false,
        showReset: false,
      }),

      searchPromoCodesResult({
        container: document.querySelector('.search-results-promo-codes'),
      }),

      instantsearch.widgets.configure({
        hitsPerPage: 10,
        distinct: true,
        clickAnalytics: true,
      }),

      instantsearch.widgets.pagination({
        container: '.promo-codes-pagination',
        scrollTo: false,
        showFirst: false,
        showLast: false,
      }),
    ]);

    search.start();

  };

  module.PromoCodesSearch = {
    initSearchPromoCodes: initSearchPromoCodes
  };
})(window.ST);