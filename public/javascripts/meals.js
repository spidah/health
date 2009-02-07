$(function() {
  var calculateTotal = function() {
    var total = 0;
    $('table#meals tr td.calories').each(function() {
      total += parseInt($(this).text());
    });
    $('table#meals tr td.total-calories').text(total);
  };

  $('table#meals tr td form input').live('click', function() {
    var row = $(this).parent().parent().parent().get(0);
    $.ajax({
      type: 'PUT',
      url: $($(this).parent().get(0)).attr('action'),
      data: "authenticity_token=" + encodeURIComponent(AUTH_TOKEN) + "&submit=" + $(this).attr('name'),
      success: function(html) {
        $(row).before(html).remove();
        calculateTotal();
      }
    });
    return false;
  });
});

jQuery.ajaxSetup({'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript");}});

