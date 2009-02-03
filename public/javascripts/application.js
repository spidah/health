$(function() {
  $('a.hide-flash').click(function() {
    $(this).parent().parent().hide("slide", {direction: "up"});
    return false;
  });
});

