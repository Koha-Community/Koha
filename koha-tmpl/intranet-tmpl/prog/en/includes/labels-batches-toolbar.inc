<div id="toolbar">
    <script type="text/javascript">
        //<![CDATA[
        function Plugin(batch_id) {
            window.open("label-item-search.pl?batch_id="+batch_id+"&amp;type=labels",'FindABibIndex','width=875,height=400,toolbar=no,scrollbars=yes');
            return false;
        }
        // prepare DOM for YUI Toolbar
         $(document).ready(function() {
            $("#additemsc").empty();
            yuiToolbar();
         });
        // YUI Toolbar Functions
        function yuiToolbar() {
            new YAHOO.widget.Button({
                id: "additems", 
                type: "link", 
                href: "#",
                label: _("Add item(s) to batch"), 
                container: "additemsc",
                onclick: {fn:function(){Plugin(<!-- TMPL_VAR NAME="batch_id" -->)}}
            });
            new YAHOO.widget.Button("deletebatch");
            new YAHOO.widget.Button("dedup");
            new YAHOO.widget.Button("generate");
        }
        //]]>
    </script>
    <ul class="toolbar">
        <li id="additemsc"><a id="additems" href="#">Add item(s) to batch</a></li>
        <li><a id="deletebatch" href="/cgi-bin/koha/labels/label-manage.pl?op=delete&amp;label_element=batch&amp;element_id=<!-- TMPL_VAR NAME="batch_id" -->">Delete current batch</a></li>
                                <!-- FIXME: should use POST to change server state, not GET -->
        <li><a id="dedup" href="/cgi-bin/koha/labels/label-manager.pl?op=deduplicate&amp;batch_id=<!-- TMPL_VAR NAME="batch_id" -->&amp;type=<!-- TMPL_VAR NAME="batch_type" -->">Remove duplicates</a></li>
        <li><a id="generate" href="/cgi-bin/koha/labels/label-print-<!-- TMPL_VAR NAME="outputformat" -->.pl?batch_id=<!-- TMPL_VAR NAME="batch_id" -->&amp;type=<!-- TMPL_VAR NAME="batch_type" -->">Generate labels for Batch</a></li>
    </ul>
</div>
