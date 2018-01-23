[% INCLUDE 'format_price.inc' %]
<link rel="stylesheet" type="text/css" href="[% interface %]/[% theme %]/css/buttons.dataTables.min_[% KOHA_VERSION %].css" />
<script type="text/javascript" src="[% interface %]/lib/jquery/plugins/jquery.dataTables.min_[% KOHA_VERSION %].js"></script>
<script type="text/javascript" src="[% interface %]/lib/jquery/plugins/dataTables.buttons.min_[% KOHA_VERSION %].js"></script>
<script type="text/javascript" src="[% interface %]/lib/jquery/plugins/buttons.colVis.min_[% KOHA_VERSION %].js"></script>
<script type="text/javascript">
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
    var MSG_DT_ALL = _("All");
    var CONFIG_EXCLUDE_ARTICLES_FROM_SORT = _("a an the");
//]]>
</script>
<script type="text/javascript" src="[% interface %]/[% theme %]/js/datatables_[% KOHA_VERSION %].js"></script>
