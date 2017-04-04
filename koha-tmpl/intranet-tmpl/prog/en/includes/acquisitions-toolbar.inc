[% INCLUDE 'blocking_errors.inc' %]
<script type="text/javascript">
//<![CDATA[
function confirm_deletion() {
    if (confirm(_("Are you sure you want to delete this vendor?"))) {
        window.location="/cgi-bin/koha/acqui/supplier.pl?booksellerid=[% booksellerid %]&op=delete";
    }
}
//]]>
</script>
<div id="toolbar" class="btn-toolbar">
    [% IF ( booksellerid ) %]
        <div class="btn-group">
        <a class="btn btn-default btn-sm dropdown-toggle" data-toggle="dropdown" href="#"><i class="fa fa-plus"></i> New
        <span class="caret"></span>
        </a>
        <ul class="dropdown-menu">
            [% IF CAN_user_acquisition_order_manage && active %]
                <li><a href="/cgi-bin/koha/acqui/basketheader.pl?booksellerid=[% booksellerid %]&amp;op=add_form">Basket</a></li>
            [% END %]
            [% IF CAN_user_acquisition_contracts_manage && active %]
                <li><a href="/cgi-bin/koha/admin/aqcontract.pl?op=add_form&amp;booksellerid=[% booksellerid %]">Contract</a></li>
            [% END %]
            [% IF ( CAN_user_acquisition_vendors_manage ) %]
                <li><a href="/cgi-bin/koha/acqui/supplier.pl?op=enter">Vendor</a></li>
            [% END %]
        </ul>
        </div>
            [% IF ( CAN_user_acquisition_vendors_manage ) %]
                <div class="btn-group"><a class="btn btn-default btn-sm" id="editsupplier" href="/cgi-bin/koha/acqui/supplier.pl?booksellerid=[% booksellerid %]&amp;op=enter"><i class="fa fa-pencil"></i> Edit vendor</a></div>
                [% UNLESS ( basketcount OR subscriptioncount ) %]
                    <div class="btn-group"><a class="btn btn-default btn-sm" id="deletesupplier" href="javascript:confirm_deletion()"><i class="fa fa-trash"></i> Delete vendor</a></div>
                [% END %]
            [% END %]
            [% IF CAN_user_acquisition_order_receive && basketcount %]
                <div class="btn-group"><a class="btn btn-default btn-sm" id="receive" href="/cgi-bin/koha/acqui/parcels.pl?booksellerid=[% booksellerid %]"><i class="fa fa-inbox"></i> Receive shipments</a></div>
            [% END %]
        [% ELSE %]
            <div class="btn-group"><a class="btn btn-default btn-sm" href="/cgi-bin/koha/acqui/supplier.pl?op=enter"><i class="fa fa-plus"></i> New vendor</a></div>
        [% END %]
</div>
