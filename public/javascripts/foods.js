$(function() {
  $('table#meals tr td form input').live('click', function() {
    var row = $(this).parent().parent().parent().get(0);
    $.ajax({
      type: 'PUT',
      url: $($(this).parent().get(0)).attr('action'),
      data: "authenticity_token=" + encodeURIComponent(AUTH_TOKEN) + "&submit=" + $(this).attr('name'),
      success: function(html) {
        $(row).before(html).remove();
      }
    });
    return false;
  });

  $('table#foods tr td.add form input').live('click', function() {
    var row = $(this).parent().parent().parent().get(0);
    var form = $(this).parent().get(0);
    var action_type = $(form).find('input[name=action_type]').attr('value');

    var method_input = $(form).find('input[name=_method]');
    var method = '';
    if (method_input.length == 1) {
      method = '&_method=' + $(method_input).attr('value');
    }

    var food_id = '&food_id=' + $(form).find('input[name=food_id]').attr('value');

    $.ajax({
      type: 'POST',
      url: $(form).attr('action'),
      data: "authenticity_token=" + encodeURIComponent(AUTH_TOKEN) + method + food_id + "&submit=" + $(this).attr('name') +
        "&action_type=" + action_type,
      success: function(html) {
        $(row).before(html).remove();
      }
    });
    return false;
  });
});

jQuery.ajaxSetup({'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript");}});
