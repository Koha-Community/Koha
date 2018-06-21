<script type="text/javascript">
    /* Strings for translation */
    var MSG_REPLACE_RECORD = _("Please note that this external search could replace the current record.");
    var MSG_DELETE_ALL_ITEMS = _("%s item(s) are attached to this record. You must delete all items before deleting this record.");
    var CONFIRM_RECORD_USED_IN_ORDERS = _("Warning: This record is used in %s order(s). Deleting it could cause serious issues on acquisition module. Are you sure you want to delete this record?");
    var MSG_RECORD_USED_IN_ORDERS = _("%s order(s) are using this record. You need order managing permissions to delete this record.");
    var CONFIRM_IN_DELETED_ORDERS = _("%s deleted order(s) are using this record. Are you sure you want to delete this record?");
    var MSG_IN_DELETED_ORDERS = _("%s deleted order(s) are using this record. You need order managing permissions to delete this record.");
    var CONFIRM_DELETION_HOLDS = _("%s holds(s) for this record. Are you sure you want to delete this record?");
    var CONFIRM_RECORD_DELETION = _("Are you sure you want to delete this record?");
    var MSG_DELETE_ALL_HOLDS = _("%s hold(s) on this record. You must delete all holds before deleting all items.");
    var CONFIRM_DELETE_ITEMS = _("Are you sure you want to delete the %s attached items?");
    var MSG_NO_ITEMS = _("This record has no items.");

    /* Some required variables from the template */
    var biblionumber = [% biblionumber %];
    var count = [% count %];
    var holdcount = [% holdcount %];
    var countorders = [% countorders %];
    var countdeletedorders = [% countdeletedorders %];

    /* provide Z3950 search points */
    function GetZ3950Terms(){
        var strQuery="&frameworkcode=";
        [% FOREACH z3950_search_param IN z3950_search_params %]
            strQuery += "&" + "[% z3950_search_param.name |uri %]" + "=" + "[% z3950_search_param.value |uri %]";
        [% END %]
        return strQuery;
    }
</script>
