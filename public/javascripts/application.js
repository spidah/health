$(function() {
  $('a.hide-flash').click(function() {
    $(this).parent().parent().hide("slide", {direction: "up"});
    return false;
  });


  $('a#logout').click(function() {
    var f = document.createElement('form');
    f.style.display = 'none';
    this.parentNode.appendChild(f);
    f.method = 'POST'; f.action = this.href;
    var m = document.createElement('input');
    m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'delete');
    f.appendChild(m);
    var s = document.createElement('input');
    s.setAttribute('type', 'hidden'); s.setAttribute('name', 'authenticity_token'); s.setAttribute('value', AUTH_TOKEN);
    f.appendChild(s);
    f.submit();
    return false;
  });
});

