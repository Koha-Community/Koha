[% USE raw %]
[% USE Asset %]
[% Asset.js("lib/jquery/plugins/jquery.dataTables.min.js") | $raw %]
[% Asset.js("lib/jquery/plugins/dataTables.responsive.min.js") | $raw %]
<script>
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
    var MSG_DT_COPY_TO_CLIPBOARD = _("Copy to clipboard");
    var MSG_DT_COPY_KEYS = _("Press <i>ctrl</i> or <i>⌘</i> + <i>C</i> to copy the table data<br>to your system clipboard.<br><br>To cancel, click this message or press escape.");
    var MSG_DT_COPIED_ROWS = _("Copied %d rows to clipboard");
    var MSG_DT_COPIED_ONE_ROW = _("Copied one row to clipboard");
    var MSG_CLEAR_FILTER = _("Clear filter");
    var MSG_DT_ALL = _("All");
    var CONFIG_EXCLUDE_ARTICLES_FROM_SORT = _("a an the");
</script>
[% Asset.js("js/datatables.js") | $raw %]
