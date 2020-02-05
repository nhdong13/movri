window.SearchMobile = {
  run: function(){
    $('.search-mobile').click(function(){
      $('.header-search-box').css('display', 'flex');
      $('.back-to-menu').click(function(){
        $('.header-search-box').css('display', 'none');
      })
    })
  }
}