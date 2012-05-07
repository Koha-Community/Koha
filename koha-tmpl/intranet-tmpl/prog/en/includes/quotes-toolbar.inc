<script type="text/javascript">
    //<![CDATA[
    // prepare DOM for YUI Toolbar
    $(document).ready(function() {
        $("#add_quote").empty();
        $("#delete_quote").empty();
        $("#import_quotes").empty();
        yuiToolbar();
     });

    // YUI Toolbar Functions
    function yuiToolbar() {

        new YAHOO.widget.Button({
            type: "button",
            label: _("Add quote"),
            name: "add",
            container: "add_quote",
            onclick: {fn: fnClickAddRow}
        });

        new YAHOO.widget.Button({
            type: "button",
            label: _("Delete quote(s)"),
            name: "delete",
            container: "delete_quote",
            onclick: {fn: fnClickDeleteRow}
        });

        new YAHOO.widget.Button({
            type: "button",
            label: _("Import quotes"),
            name: "import",
            container: "import_quotes",
            onclick: {fn: function (){parent.location="quotes-upload.pl";}}
        });
    }

//]]>
</script>
<div id="toolbar">
    <ul class="toolbar">
        <li id="add_quote"><a id="add" href="#">Add quote</a></li>
        <li id="delete_quote"><a id="delete" href="#">Delete quote(s)</a></li>
        <li id="import_quotes"><a id="import" href="#">Import quotes</a></li>
    </ul>
</div>
