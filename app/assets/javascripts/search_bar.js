$(document).ready(function() {
  const search = instantsearch({
    indexName: 'Listing',
    searchClient: algoliasearch(
      'I9M2XD27BV',
      '30b73223325eca9f17cfbe9fea6a9775'
    ),
  });

  const renderHits = (renderOptions, isFirstRender) => {
    if (isFirstRender) {
      $('#hits').hide()
    }
    const { hits, widgetParams } = renderOptions;
    widgetParams.container.innerHTML = `
      <div class="snize-ac-results">
        <div class="snize-ac-results-column">
          <p>Products</p>
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
                        <span> $100</span>
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
  };

  // Create the custom widget
  const customHits = instantsearch.connectors.connectHits(renderHits);

  search.addWidgets([
    instantsearch.widgets.searchBox({
      container: '#searchbox',
      placeholder: 'Search for products',
      showSubmit: false,
      showReset: false,
    }),

    customHits({
      container: document.querySelector('#hits'),
    }),

    instantsearch.widgets.configure({
      hitsPerPage: 15,
      distinct: true,
      clickAnalytics: true,
    })
  ]);

  search.start();

  $('.header-search-input').focus(function() {
    if (localStorage.search_history == '') {
      return;
    }
    $('.history-keywords').empty();
    var historyKeywords = localStorage.search_history.split(',').reverse();
    var numberOfKeyword = 0;

    $.each(historyKeywords, function(idx, keyword){
      if ((historyKeywords[idx+1] == keyword) || keyword == '') {
        return true;
      }
      if ((numberOfKeyword > 5)) {
        return false;
      }
      var htmlSearchHistoryItem = '';
      htmlSearchHistoryItem += '<li class="history-keyword-item" data-text-search="'+ keyword +'">';
      htmlSearchHistoryItem += '<a href="/?q='+ keyword +'">';
      htmlSearchHistoryItem += '<img src="/assets/mf_icons/icon-movri-undo.svg" class="history-keyword-icon">';
      htmlSearchHistoryItem += '<span class="link-text ta-ellipsis">' + keyword + '</span>';
      htmlSearchHistoryItem += '<img src="/assets/mf_icons/icon-movri-visit.svg" class="visit-search-icon">'
      htmlSearchHistoryItem += '</a>';
      htmlSearchHistoryItem += '</li>';
      $('.history-keywords').append(htmlSearchHistoryItem);
      numberOfKeyword += 1
    });
    htmlClearSearchHistory = '<li class="clear-history-keywords">';
    htmlClearSearchHistory += '<a href="javascript:void(0)">';
    htmlClearSearchHistory += '<img src="/assets/mf_icons/icon-movri-undo.svg" class="reset-history-keyword-icon">';
    htmlClearSearchHistory += '<span class="link-text ta-ellipsis">Clear search history</span>';
    htmlClearSearchHistory += '</a>';
    htmlClearSearchHistory += '</li>';
    $('.history-keywords').append(htmlClearSearchHistory);
  })

  $(document).keypress(function(event){
    var keycode = (event.keyCode ? event.keyCode : event.which);
    if(keycode == '13'){
      if ($('.header-search-input').is(':focus')) {
      };
    }
  });

  $(document).click (function (e) {
    var search_result = $('#hits');
    if (e.target == $('#searchbox input')[0] || $(e.target).parents('#hits')[0] == $('#hits')[0]) {
      $(search_result).show();
    } else {
      $(search_result).hide();
    }
  });
});