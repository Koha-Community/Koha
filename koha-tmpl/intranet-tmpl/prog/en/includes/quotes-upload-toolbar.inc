<script type="text/javascript">
    var oSaveButton = '';
    var oDeleteButton = '';
    //<![CDATA[
    // prepare DOM for YUI Toolbar
    $(document).ready(function() {
        $("#save_quotes").empty();
        $("#delete_quote").empty();
        yuiToolbar();
     });

    // YUI Toolbar Functions
    function yuiGetData() {
        fnGetData(document.getElementById('quotes_editor'));
    }

    function yuiToolbar() {

        oSaveButton = new YAHOO.widget.Button({
            type: "button",
            label: _("Save quotes"),
            name: "save",
            container: "save_quotes",
        });

        oDeleteButton = new YAHOO.widget.Button({
            type: "button",
            label: _("Delete quote(s)"),
            name: "delete",
            container: "delete_quote",
        });
    }

//]]>
</script>
<div id="toolbar">
    <ul class="toolbar">
        <li id="save_quotes"><a id="save" href="#">Save quotes</a></li>
        <li id="delete_quote"><a id="delete" href="#">Delete quote(s)</a></li>
        <span class="hint" style="">Click Source or Text field to edit contents. Press &lt;Enter&gt; to save changes.</span>
    </ul>
</div>
