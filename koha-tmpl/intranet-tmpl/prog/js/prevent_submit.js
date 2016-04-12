$(document).ready(function() {
  // We don't want to apply this for the search form
  $("#doc3 form").keypress(function (e) {
    if( e.which == 13
        && e.target.nodeName == "INPUT"
        && e.target.type != "submit"
    ) {
        return false;
    }
  });
});
