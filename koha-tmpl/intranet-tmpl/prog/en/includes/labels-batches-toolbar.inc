<div id="toolbar">
    <script type="text/JavaScript">
        //<![CDATA[
           function DeleteConfirm() {
                var msg = "Are you sure you want to delete batch <!-- TMPL_VAR NAME="batch_id" -->?"
                var answer = confirm(msg);
                if (answer) {
                    window.location = "/cgi-bin/koha/labels/label-manage.pl?op=delete&amp;label_element=batch&amp;element_id=<!-- TMPL_VAR NAME="batch_id" -->";
                }
                else {
                    return; // abort delete
                }
            };
            function Remove() {
                items = new Array;
                item_num = new Array;
                if(document.items.action.length > 0) {
                    for (var i=0; i < document.items.action.length; i++) {
                        if (document.items.action[i].checked) {
                            items.push("label_id=" +  document.items.action[i].value);
                            item_num.push(i+1);
                        }
                    }
                    if (items.length < 1) {
                        alert("Please select at least one item to delete.");
                        return;     // no item selected
                    }
                    getstr = items.join("&");
                    item_msg = item_num.join(", ");
                    var msg = "Are you sure you want to remove label number(s): " + item_msg + " from this batch?"
                }
//                else if (document.items.action.checked) {
//                    getstr = "label_id="+document.items.action.value;
//                    var msg = "Are you sure you want to remove selected item from this batch?"
//                }
                else {
                    alert("Please select at least label to delete.");
                    return;     // no item selected
                }
                var answer = confirm(msg);
                if (answer) {
                    window.location = "/cgi-bin/koha/labels/label-edit-batch.pl?op=remove&amp;batch_id=<!-- TMPL_VAR NAME="batch_id" -->&amp;" + getstr;
                }
                else {
                    return; // abort delete
                }
            };
            function Add() {
                window.open("/cgi-bin/koha/labels/label-item-search.pl?batch_id=<!-- TMPL_VAR NAME="batch_id" -->&amp;type=labels",'FindABibIndex','width=875,height=400,toolbar=no,scrollbars=yes');
            };
            function DeDuplicate() {
                window.location = "/cgi-bin/koha/labels/label-edit-batch.pl?op=de_duplicate&amp;batch_id=<!-- TMPL_VAR NAME="batch_id" -->";
            };
            function Xport(mode) {
                if (mode == 'label') {
                    labels= new Array;
                    if(document.items.action.length > 0) {
                        for (var i=0; i < document.items.action.length; i++) {
                            if (document.items.action[i].checked) {
                                labels.push("label_id=" +  document.items.action[i].value);
                            }
                        }
                        if (labels.length < 1) {
                            alert("Please select at least one label to export.");
                            return;     // no batch selected
                        }
                        getstr = labels.join("&");
                    }
                    else if (document.items.action.checked) {
                        getstr = document.items.action.value;
                    }
                    else {
                        alert("Please select at least one label to export.");
                        return;     // no batch selected
                    }
                    return GB_showCenter('Export Labels', "/cgi-bin/koha/labels/label-print.pl?batch_id=<!-- TMPL_VAR NAME="batch_id" -->&" + getstr, 700, 800);
                }
                else if (mode == 'batch') {
                    return GB_showCenter('Export Labels', "/cgi-bin/koha/labels/label-print.pl?batch_id=<!-- TMPL_VAR NAME="batch_id" -->", 700, 800);
                }
                else {
                    // some pass-thru error trapping just in case...
                }
            };
           function selected_layout() {
                if (document.items.action.length) {
                for (i=0;i<document.items.action.length;i++){
                    if (document.items.action[i].checked==true){
                        return(document.items.action[i].value);
                    }
                };
                }
                else {
                    if (document.items.action.checked){
                        return(document.items.action.value);
                    }
                };
                alert("Please select at least one item.");
                return (-1);
            };

        // prepare DOM for YUI Toolbar
         $(document).ready(function() {
            $("#additemsc").empty();
            $("#removeitemsc").empty();
            $("#deletebatchc").empty();
            $("#deduplicatec").empty();
            $("#exportitemsc").empty();
            $("#exportbatchc").empty();
            yuiToolbar();
         });
        // YUI Toolbar Functions
        function yuiToolbar() {
            new YAHOO.widget.Button({
                id: "additems", 
                type: "link", 
                href: "#",
                label: _("Add Item(s)"), 
                container: "additemsc",
                onclick: {fn:function(){Add()}}
            });

            new YAHOO.widget.Button({
                id: "removeitems", 
                type: "link", 
                href: "#",
                label: _("Remove Item(s)"), 
                container: "removeitemsc",
                onclick: {fn:function(){Remove()}}
            });

            new YAHOO.widget.Button({
                id: "deletebatch", 
                type: "link", 
                href: "#",
                label: _("Delete Batch"), 
                container: "deletebatchc",
                onclick: {fn:function(){DeleteConfirm()}}
            });

            new YAHOO.widget.Button({
                id: "deduplicate", 
                type: "link", 
                href: "#",
                label: _("Remove Duplicates"), 
                container: "deduplicatec",
                onclick: {fn:function(){DeDuplicate()}}
            });

            new YAHOO.widget.Button({
                id: "exportitems", 
                type: "link", 
                href: "#",
                label: _("Export Item(s)"), 
                container: "exportitemsc",
                onclick: {fn:function(){Xport('label')}}
            });

            new YAHOO.widget.Button({
                id: "exportbatch", 
                type: "link", 
                href: "#",
                label: _("Export Batch"), 
                container: "exportbatchc",
                onclick: {fn:function(){Xport('batch')}}
            });
            new YAHOO.widget.Button("deletebatch");
        }
        //]]>
    </script>
    <ul class="toolbar">
        <li id="additemsc"><a id="additems" href="#">Add Item(s)</a></li>
        <li id="removeitemsc"><a id="removeitems" href="#">Remove Item(s)</a></li>
        <li id="deletebatchc"><a id="deletebatch" href="#">Delete Batch</a></li>
        <li id="deduplicatec"><a id="deduplicate" href="#">Remove Duplicates</a></li>
        <li id="exportitemsc"><a id="exportitems" href="#">Export Item(s)</a></li>
        <li id="exportbatchc"><a id="exportbatch" href="#">Export Batch</a></li>
    </ul>
</div>
