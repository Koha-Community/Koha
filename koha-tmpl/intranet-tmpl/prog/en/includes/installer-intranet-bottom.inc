        <script src="[% interface %]/lib/jquery/jquery-2.2.3.min.js"></script>
        <script src="[% interface %]/lib/jquery/jquery-migrate-1.3.0.min.js"></script>
        <script src="[% interface %]/lib/jquery/jquery-ui-1.11.4.min.js"></script>
        <script src="[% interface %]/lib/bootstrap/bootstrap.min.js"></script>
        <script src="[% interface %]/lib/jquery/plugins/jquery.validate.min.js"></script>
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
        [% jsinclude # Parse the page template's JavaScript block if necessary %]
    </body>
</html>
