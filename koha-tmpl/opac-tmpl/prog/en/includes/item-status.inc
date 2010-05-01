<!-- TMPL_IF name="notforloan_per_itemtype" -->
    Not for loan <!-- TMPL_IF NAME="notforloanvalue" -->(<!-- TMPL_VAR NAME="notforloanvalue" -->)<!-- /TMPL_IF -->
<!-- TMPL_ELSE -->
    <!-- TMPL_IF name="datedue" -->
        <!-- TMPL_IF name="OPACShowCheckoutName" -->
            Checked out to <!-- TMPL_VAR NAME="cardnumber" --> <!-- TMPL_VAR NAME="firstname" --> <!-- TMPL_VAR NAME="surname" -->
        <!-- TMPL_ELSE -->
            Checked out
        <!-- /TMPL_IF -->
    <!-- TMPL_ELSE -->
        <!-- TMPL_IF name="itemnotforloan" -->
            <!-- TMPL_VAR NAME="notforloanvalue" -->
        <!-- TMPL_ELSE -->
            <!-- TMPL_IF name="itemlost"-->
                <!-- TMPL_IF name="lostimageurl"-->
                    <img src="<!-- TMPL_VAR NAME="lostimageurl" -->" alt="<!-- TMPL_VAR NAME="lostimagelabel" -->" title="<!-- TMPL_VAR NAME="lostimagelabel" -->">
                <!-- TMPL_ELSE -->
                    Item lost
                <!-- /TMPL_IF -->
            <!-- TMPL_ELSE -->
                <!-- TMPL_IF NAME="wthdrawn" -->
                    Item withdrawn
                <!-- TMPL_ELSIF NAME="damaged" -->
                    Item damaged
                <!-- TMPL_ELSIF Name="transfertwhen" -->
                    In transit from <!-- TMPL_VAR NAME="transfertfrom" -->
                    to <!-- TMPL_VAR NAME="transfertto" --> since <!-- TMPL_VAR NAME="transfertwhen" -->
                <!-- TMPL_ELSE -->
                    <!-- TMPL_IF NAME="waiting" -->On hold<!-- TMPL_ELSE -->Available<!-- /TMPL_IF -->
                <!-- /TMPL_IF -->
            <!-- /TMPL_IF -->
        <!-- /TMPL_IF -->
    <!-- /TMPL_IF -->
<!-- /TMPL_IF -->
