window.SearchMobile = {
  run: function(){
    $('.search-mobile-icon').click(function(){
      $('.mobile-display .searchbox-algolia input').css('display', 'inline-block');
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