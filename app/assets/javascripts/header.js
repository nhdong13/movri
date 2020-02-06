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

window.ToggleCat = {
  run: function(){
    $('.toggle-cat').click(function(){
      $(".cat-section .the-rest").slideToggle();
      $('.cat-section .all, .cat-section .less').toggle();
    })
  }
}