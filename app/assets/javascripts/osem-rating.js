$(function () {
  $( document ).ready(function() {
    var checkedId = $("a[voted='true']").attr('id');
    $('a[id=' + checkedId + ']').prevAll().andSelf().addClass('bright');

    $(".myrating").hover(
      function() {    // mouseover
          $(this).prevAll().andSelf().addClass('glow');
      },
      function() {  // mouseout
          $(this).siblings().andSelf().removeClass('glow');
      }
    );

    $(".myrating").click(function() {
      $(this).siblings().removeClass("bright");
      $(this).prevAll().andSelf().addClass("bright");
    });
  });
});
