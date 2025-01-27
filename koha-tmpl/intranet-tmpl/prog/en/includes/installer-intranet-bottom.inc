[% USE raw %]
[% USE Asset %]
[% Asset.js("lib/jquery/jquery-3.6.0.min.js") | $raw %]
[% Asset.js("lib/jquery/jquery-migrate-3.3.2.min.js") | $raw %]
[% Asset.js("lib/jquery/jquery-ui-1.13.2.min.js") | $raw %]
[% Asset.js("lib/bootstrap/bootstrap.bundle.min.js") | $raw %]
[% Asset.js("lib/jquery/plugins/jquery.validate.min.js") | $raw %]
<!-- installer-intranet-bottom.inc -->
<script>
    function _(s) { return s } // dummy function for gettext
    [%# Prevent XFS attacks -%]
    $(document).ready(function() {
       if (self === top) {
           var antiClickjack = document.getElementById("antiClickjack");
           antiClickjack.parentNode.removeChild(antiClickjack);
       } else {
           top.location = self.location;
       }
    });
</script>
<!-- / installer-intranet-bottom.inc -->
[% INCLUDE 'calendar.inc' %]
[% jsinclude | $raw # Parse the page template's JavaScript block if necessary %]
</body>
<!-- prettier-ignore-start -->
</html>
<!-- prettier-ignore-end -->
