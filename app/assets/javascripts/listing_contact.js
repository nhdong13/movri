window.ST = window.ST || {};

window.ST.ListingContact = (function() {
  function contactFormSlider() {
    $('.trade-in-your-gear-email').on('click', function() {
      $('.side-mail-response').hide();
      $('.side-mail-wrap').show();
      $('#sideEmail').css('width', '100%');
      $('#sideEmail').css('padding-left', '50%');
      $('.sidenav').css('width', '50%');
      $('.overlap-sidenav').css('display', 'block');
      $('#contact_subject').focus();
    });

    $('.closebtn').on('click', function() {
      $('#sideEmail').css('width', '0');
      $('.overlap-sidenav').css('display', 'none');
      $('.sidenav').css('width', '0');
    })
  };

  return {
    contactFormSlider: contactFormSlider
  };
})();