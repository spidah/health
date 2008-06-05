setup_calendar = function() {
  Calendar.setup(
    {
      inputField  : "date_picker",
      ifFormat    : "%e %B %Y",
      button      : "date_picker",
      align       : "tl",
      singleClick : false,
      onClose     : function onDateClose(cal) { document.getElementById("date_picker_form").submit(); }
    }
  );
}
if (window.attachEvent)
  window.attachEvent("onload", setup_calendar);