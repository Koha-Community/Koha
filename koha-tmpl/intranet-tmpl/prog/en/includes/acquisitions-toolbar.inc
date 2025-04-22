<!-- acquisitions-toolbar.inc -->
[% INCLUDE 'modals/delete_vendor.inc' %]
<div id="toolbar" class="btn-toolbar">
    [% IF ( booksellerid ) %]
        <div class="btn-group">
            <a class="btn btn-default dropdown-toggle" data-bs-toggle="dropdown" href="#"><i class="fa fa-plus"></i> New</a>
            <ul class="dropdown-menu">
                [% IF CAN_user_acquisition_order_manage && active %]
                    <li><a class="dropdown-item" href="/cgi-bin/koha/acqui/basketheader.pl?booksellerid=[% booksellerid | uri %]&amp;op=add_form">Basket</a></li>
                [% END %]
                [% IF CAN_user_acquisition_contracts_manage && active %]
                    <li><a class="dropdown-item" href="/cgi-bin/koha/admin/aqcontract.pl?op=add_form&amp;booksellerid=[% booksellerid | uri %]">Contract</a></li>
                [% END %]
                [% IF ( CAN_user_acquisition_vendors_manage ) %]
                    <li><a class="dropdown-item" href="/cgi-bin/koha/acquisition/vendors/add">Vendor</a></li>
                [% END %]
            </ul>
        </div>
        [% IF ( CAN_user_acquisition_vendors_manage ) %]
            <div class="btn-group">
                <a class="btn btn-default" id="editsupplier" href="/cgi-bin/koha/acquisition/vendors/[% booksellerid | html %]"><i class="fa-solid fa-pencil" aria-hidden="true"></i> Edit vendor</a>
            </div>
            [% UNLESS ( basketcount OR subscriptioncount ) %]
                <div class="btn-group">
                    <button type="button" data-bs-toggle="modal" data-bs-target="#deleteVendorModal" data-booksellerid="[% booksellerid | html %]" class="btn btn-default"><i class="fa fa-trash-can"></i> Delete vendor</button>
                </div>
            [% END %]
        [% END %]
        [% IF CAN_user_acquisition_order_receive && basketcount && active %]
            <div class="btn-group"
                ><a class="btn btn-default" id="receive" href="/cgi-bin/koha/acqui/parcels.pl?booksellerid=[% booksellerid | html %]"><i class="fa fa-inbox"></i> Receive shipments</a></div
            >
        [% END %]
    [% ELSIF ( CAN_user_acquisition_vendors_manage ) %]
        <div class="btn-group"
            ><a class="btn btn-default" href="/cgi-bin/koha/acquisition/vendors/add"><i class="fa fa-plus"></i> New vendor</a></div
        >
    [% END %]
</div>
<!-- / acquisitions-toolbar.inc -->
