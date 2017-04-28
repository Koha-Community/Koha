<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="shortcut icon" href="/favicon.ico" type="image/x-icon" />
<link rel="stylesheet" type="text/css" href="[% interface %]/lib/jquery/jquery-ui-1.11.4.min.css" />
<link rel="stylesheet" type="text/css" href="[% interface %]/lib/bootstrap/bootstrap.min.css" />
<link rel="stylesheet" type="text/css" href="[% interface %]/[% theme %]/css/installer.css" />

<script type="text/javascript" src="[% interface %]/lib/jquery/jquery-2.2.3.min.js"></script>
<script type="text/javascript" src="[% interface %]/lib/jquery/jquery-migrate-1.3.0.min.js"></script>
<script type="text/javascript" src="[% interface %]/lib/jquery/jquery-ui-1.11.4.min.js"></script>
<script type="text/javascript" src="[% interface %]/lib/bootstrap/bootstrap.min.js"></script>
<script type="text/javascript" src="[% interface %]/lib/jquery/plugins/jquery.validate.min.js"></script>
<script type="text/javascript">
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
<style id="antiClickjack">body{display:none !important;}</style>
