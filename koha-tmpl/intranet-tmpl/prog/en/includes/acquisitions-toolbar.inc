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
        new YAHOO.widget.Button("newbasket");
        new YAHOO.widget.Button("editsupplier");
        new YAHOO.widget.Button("deletesupplier");
        new YAHOO.widget.Button("receive");
        new YAHOO.widget.Button("newcontract");
        new YAHOO.widget.Button("editcontracts");

        var manageorders = [
            [% IF ( CAN_user_acquisition_order_manage ) %]
              [% IF (active) %]
                { text: _("New basket"), url: "/cgi-bin/koha/acqui/basketheader.pl?booksellerid=[% booksellerid %]&op=add_form"},
              [% END %]
                { text: _("Baskets"), url: "/cgi-bin/koha/acqui/booksellers.pl?booksellerid=[% booksellerid %]"},
                { text: _("Basket groups"), url: "/cgi-bin/koha/acqui/basketgroup.pl?booksellerid=[% booksellerid %]"},
            [% END %]
            { text: _("Receive shipments"), url: "/cgi-bin/koha/acqui/parcels.pl?booksellerid=[% booksellerid %]" },
            [% IF ( basketno ) %]
                { text: _("Uncertain prices"), url: "/cgi-bin/koha/acqui/uncertainprice.pl?booksellerid=[% booksellerid %]&basketno=[% basketno %]&owner=1"}
            [% ELSE %]
                { text: _("Uncertain prices"), url: "/cgi-bin/koha/acqui/uncertainprice.pl?booksellerid=[% booksellerid %]&owner=1"}
            [% END %]
        ]
        [% IF ( booksellerid ) %]
            [% IF ( basketcount ) %]
                new YAHOO.widget.Button({type: "menu", label: _("Manage orders"), name: "manageorders", menu: manageorders, container: "toolbar-list"});
            [% END %]
        [% END %]
    }

    //]]>
    </script>
    <ul id="toolbar-list" class="toolbar">
        [% IF ( booksellerid ) %]
            [% IF ( CAN_user_acquisition_vendors_manage ) %]
                <li><a id="editsupplier" href="/cgi-bin/koha/acqui/supplier.pl?booksellerid=[% booksellerid %]&amp;op=enter">Edit</a></li>
                [% UNLESS ( basketcount OR subscriptioncount ) %]
                    <li><a id="deletesupplier" href="javascript:confirm_deletion()">Delete</a></li>
                [% END %]
                <li><a id="newcontract" href="/cgi-bin/koha/admin/aqcontract.pl?op=add_form&amp;booksellerid=[% booksellerid %]">New contract</a></li>
                <li><a id="editcontracts" href="/cgi-bin/koha/admin/aqcontract.pl?booksellerid=[% booksellerid %]">Contracts</a></li>
                [% IF (active && !basketcount) %]
                    <li><a id="newbasket" href="/cgi-bin/koha/acqui/basketheader.pl?booksellerid=[% booksellerid %]&amp;op=add_form">New basket</a></li>
                [% END %]
            [% END %]
        [% ELSE %]
            <li><a id="newbudget" href="/cgi-bin/koha/acqui/supplier.pl?op=enter">New vendor</a></li>
        [% END %]
    </ul>
</div>
