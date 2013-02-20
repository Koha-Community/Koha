<div id="toolbar"><script type="text/javascript">
    //<![CDATA[

    // prepare DOM for YUI Toolbar

    $(document).ready(function() {
        yuiToolbar();
    });

    // YUI Toolbar Functions

    function yuiToolbar() {
        new YAHOO.widget.Button("editsupplier");
        new YAHOO.widget.Button("deletesupplier");
        new YAHOO.widget.Button("receive");
        [% UNLESS ( booksellerid ) %]new YAHOO.widget.Button("newvendor");[% END %]

        var newmenu = [
            [% IF ( CAN_user_acquisition_order_manage ) %]
                { text: _("Basket"), url: "/cgi-bin/koha/acqui/basketheader.pl?booksellerid=[% booksellerid %]&op=add_form"},
            [% END %]
            [% IF ( CAN_user_acquisition_contracts_manage ) %]{ text: _("Contract"), url: "/cgi-bin/koha/admin/aqcontract.pl?op=add_form&amp;booksellerid=[% booksellerid %]"},[% END %]
            { text: _("Vendor"), url: "/cgi-bin/koha/acqui/supplier.pl?op=enter"}
        ]
        new YAHOO.widget.Button({type: "menu", label: _("New"), name: "newmenu", menu: newmenu, container: "newmenuc"});
    }

    //]]>
    </script>
    <ul id="toolbar-list" class="toolbar">
        [% IF ( booksellerid ) %]
            [% IF ( CAN_user_acquisition_vendors_manage ) %]
                <li id="newmenuc"></li>
                <li><a id="editsupplier" href="/cgi-bin/koha/acqui/supplier.pl?booksellerid=[% booksellerid %]&amp;op=enter">Edit vendor</a></li>
                [% UNLESS ( basketcount OR subscriptioncount ) %]
                    <li><a id="deletesupplier" href="javascript:confirm_deletion()">Delete vendor</a></li>
                [% END %]
            [% END %]
                [% IF ( CAN_user_acquisition_order_receive && basketcount ) %]<li><a id="receive" href="/cgi-bin/koha/acqui/parcels.pl?booksellerid=[% booksellerid %]">Receive shipments</a></li>[% END %]
        [% ELSE %]
            <li><a id="newvendor" href="/cgi-bin/koha/acqui/supplier.pl?op=enter">New vendor</a></li>
        [% END %]
    </ul>
</div>
