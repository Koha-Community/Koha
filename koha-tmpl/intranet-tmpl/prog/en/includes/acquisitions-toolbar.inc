<div id="toolbar"><script type="text/javascript">
    //<![CDATA[

    // prepare DOM for YUI Toolbar

    $(document).ready(function() {
        yuiToolbar();
    });

    // YUI Toolbar Functions

    function yuiToolbar() {   
    
        new YAHOO.widget.Button("newperiod");
        new YAHOO.widget.Button("newbudget");
        new YAHOO.widget.Button("newsupplier");

        var manageorders = [
            { text: _("New basket"), url: "/cgi-bin/koha/acqui/basketheader.pl?booksellerid=<!-- TMPL_VAR NAME="id" -->&op=add_form"},
            { text: _("Baskets"), url: "/cgi-bin/koha/acqui/booksellers.pl?supplierid=<!--TMPL_VAR Name="id"-->"},
            { text: _("Basket grouping"), url: "/cgi-bin/koha/acqui/basketgroup.pl?booksellerid=<!-- TMPL_VAR NAME="id" -->"},
            { text: _("Receive shipments"), url: "/cgi-bin/koha/acqui/parcels.pl?supplierid=<!--TMPL_VAR Name="id"-->" },
            <!-- TMPL_IF name="basketno" -->
                { text: _("Uncertain prices"), url: "/cgi-bin/koha/acqui/uncertainprice.pl?booksellerid=<!-- TMPL_VAR NAME="id" -->&basketno=<!--TMPL_VAR name="basketno" -->&owner=1"}
            <!-- TMPL_ELSE -->
                { text: _("Uncertain prices"), url: "/cgi-bin/koha/acqui/uncertainprice.pl?booksellerid=<!-- TMPL_VAR NAME="id" -->&owner=1"}
            <!-- /TMPL_IF -->
        ]
        <!-- TMPL_IF NAME="id" -->new YAHOO.widget.Button("newbasket");
        new YAHOO.widget.Button("editsupplier");
        new YAHOO.widget.Button("receive");
        new YAHOO.widget.Button("editcontracts");
        new YAHOO.widget.Button({type: "menu", label: _("Manage orders"), name: "manageorders", menu: manageorders, container: "toolbar-list"});
        <!-- /TMPL_IF -->
    }

    //]]>
    </script>
    <ul id="toolbar-list" class="toolbar">
        <!-- TMPL_IF NAME="id" -->
            <li><a id="editsupplier" href="/cgi-bin/koha/acqui/supplier.pl?supplierid=<!--TMPL_VAR Name="id"-->&amp;op=enter">Edit</a></li>
            <li><a id="editcontracts" href="/cgi-bin/koha/admin/aqcontract.pl?booksellerid=<!-- TMPL_VAR name="id" -->">Contracts</a></li>
        <!-- TMPL_ELSE -->
            <li><a id="newbudget" href="/cgi-bin/koha/acqui/supplier.pl?op=enter">New</a></li>
        <!-- /TMPL_IF -->
    </ul>
</div>
