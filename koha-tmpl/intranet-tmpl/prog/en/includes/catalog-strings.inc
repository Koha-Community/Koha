[% USE Context %]
<!-- catalog-strings.inc -->
<script>
    /* Some required variables from the template */
    var biblionumber = "[% biblionumber | html %]";
    var count = [% count || 0 | html %];
    var holdcount = [% holdcount || 0 | html %];
    [% SET orders = biblio.orders %]
    [% SET current   = Context.Scalar(orders, "filter_out_cancelled") %]
    [% SET cancelled = Context.Scalar(orders, "filter_by_cancelled") %]
    var countorders = [% current.count || 0 | html %];
    var countdeletedorders = [% cancelled.count || 0 | html %];
    var subscriptionscount = [% biblio.subscriptions.count || 0 | html %];
    var searchid = "[% searchid | html %]";

    /* provide Z3950 search points */
    function GetZ3950Terms(){
        var strQuery="&frameworkcode=";
        [% FOREACH z3950_search_param IN z3950_search_params %]
            strQuery += "&" + "[% z3950_search_param.name |uri %]" + "=" + "[% z3950_search_param.value |uri %]";
        [% END %]
        return strQuery;
    }
</script>
<!-- / catalog-strings.inc -->
