[% USE Asset %]
<script src="[% interface %]/lib/select2/js/select2.min.js"></script>
[% Asset.css("lib/select2/css/select2.min.css") %]
[% Asset.css("css/select2.css") %]
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
    formatMatches: function (matches) {
      if (matches === 1) {
        return _("One result is available, press enter to select it.");
      }
      return _("%s results are available, use up and down arrow keys to navigate.").format(matches);
    },
    formatNoMatches: function () {
      return _("No matches found");
    },
    formatInputTooShort: function (input, min) {
      var n = min - input.length;
      return _("Please enter %n or more characters").format(n);
    },
    formatInputTooLong: function (input, max) {
      var n = input.length - max;
      return _("Please delete %d character(s)").format(n);
    },
    formatSelectionTooBig: function (limit) {
      return _("You can only select %s item(s)").format(limit);
    },
    formatLoadMore: function (pageNumber) {
      return _("Loading more results…");
    },
    formatSearching: function () {
      return _("Searching…");
    }
  });
</script>
