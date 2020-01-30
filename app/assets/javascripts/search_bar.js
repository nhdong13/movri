$(document).ready(function() {
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
        saveSearchHistory();
      };
    }
  });

  $(document).on('click', '#search-button', function() {
    saveSearchHistory();
  });

  $(document).on('click', '.clear-history-keywords', function(){
    localStorage.search_history = '';
    location.reload(true);
  });

  $(document).on('keyup', '.header-search-input', function() {
    if ($(this).val() != '') {
      $('#search-history').css('display', 'none');
      $('#search-results').css('display', 'block');
      search($(this).val());
    } else {
      $('#search-history').css('display', 'block');
      $('#search-results').css('display', 'none');
    }
  });

  $(document).on('mouseover', '.history-keyword-item', function() {
    search($(this).data('text-search'));
  });

  function search(keyword) {
    var view = $('.home-toolbar-button-group').find('.selected').attr('title');
    $.ajax({
      url: "/search_listing",
      type: "POST",
      data: {
        q: keyword,
        view: view
      },
      dataType: 'script',
      success: function() {
        return;
      }
    });
  }

  function saveSearchHistory() {
    var searchValue = $('.header-search-input').val();
    if (searchValue != '') {
      var search_history = localStorage.search_history;
      if (search_history == undefined) {
        localStorage.search_history = searchValue;
      } else {
        localStorage.search_history = search_history + ',' + searchValue;
      }
    }
  };
});