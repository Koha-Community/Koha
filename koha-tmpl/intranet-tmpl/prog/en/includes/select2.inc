[% USE raw %]
[% USE Asset %]
[% Asset.js("lib/select2/js/select2.min.js") | $raw %]
[% Asset.css("lib/select2/css/select2.min.css") | $raw %]
[% Asset.css("css/select2.css") | $raw %]
<!-- select2.inc -->
<script>
  jQuery.extend($.fn.select2.defaults, {
    allowClear: true,
    width: function() {
      var width = this.element.outerWidth();

      // 18 is the width of .select2-arrow
      width -= 18;

      if (this.allowClear) {
        // 42 is the margin-right of .select2-chosen when allowClear is true
        width += 42;
      } else {
        // 26 is the margin-right of .select2-chosen when allowClear is false
        width += 26;
      }

      return width;
    },

    // Internationalization
    language: {
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
    }
  });
</script>
<!-- / select2.inc -->
