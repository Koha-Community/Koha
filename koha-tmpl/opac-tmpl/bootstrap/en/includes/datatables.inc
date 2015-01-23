[% USE raw %]
[% USE Asset %]
[% Asset.js("lib/jquery/plugins/jquery.dataTables.min.js") | $raw %]
<script>
//<![CDATA[
    var MSG_DT_FIRST = _("First");
    var MSG_DT_LAST = _("Last");
    var MSG_DT_NEXT = _("Next");
    var MSG_DT_PREVIOUS = _("Previous");
    var MSG_DT_EMPTY_TABLE = _("No data available in table");
    var MSG_DT_INFO = _("Showing _START_ to _END_ of _TOTAL_");
    var MSG_DT_INFO_EMPTY = _("No entries to show");
    var MSG_DT_INFO_FILTERED = _("(filtered from _MAX_ total entries)");
    var MSG_DT_LENGTH_MENU = _("Show _MENU_ entries");
    var MSG_DT_LOADING_RECORDS = _("Loading...");
    var MSG_DT_PROCESSING = _("Processing...");
    var MSG_DT_SEARCH = _("Search:");
    var MSG_DT_ZERO_RECORDS = _("No matching records found");
    var CONFIG_EXCLUDE_ARTICLES_FROM_SORT = _("a an the");
//]]>
</script>
[% Asset.js("js/datatables.js") | $raw %]
