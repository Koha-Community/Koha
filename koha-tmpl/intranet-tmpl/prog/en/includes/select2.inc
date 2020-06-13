[% USE raw %]
[% USE Asset %]
[% Asset.js("lib/select2/js/select2.min.js") | $raw %]
[% Asset.css("lib/select2/css/select2.min.css") | $raw %]
[% Asset.css("css/select2.css") | $raw %]
<!-- select2.inc -->
<script>
  $.fn.select2.defaults.set("allowClear", true);
  $.fn.select2.defaults.set("placeholder", "");

  // Internationalization
  $.fn.select2.defaults.set("language", {
      errorLoading:function(){return"The results could not be loaded."},
      inputTooLong:function(e){
          var n = e.input.length - e.max;
          return _("Please delete %d character(s)").format(n);
      },
      inputTooShort:function(e){
          var n = e.min - e.input.length;
          return _("Please enter %n or more characters").format(n);
      },
      formatResult: function(item) {
          return $('<div>', {title: item.element[0].title}).text(item.text);
      },
      loadingMore:function(){return"Loading more results…"},
      maximumSelected:function(e){
          return _("You can only select %s item(s)").format(e.max);
      },
      noResults:function(){return _("No results found")},
      searching:function(){return _("Searching…")},
      removeAllItems:function(){return _("Remove all items")},
      removeItem:function(){return _("Remove item")}
    });
</script>
<!-- / select2.inc -->
