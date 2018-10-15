[% IF ( booksellerid ) %]
<div id="menu">
    <ul>
        [% IF ( CAN_user_acquisition_order_manage ) %]<li><a href="/cgi-bin/koha/acqui/booksellers.pl?booksellerid=[% booksellerid | uri %]">Baskets</a></li>[% END %]
        [% IF ( CAN_user_acquisition_group_manage ) %]<li><a href="/cgi-bin/koha/acqui/basketgroup.pl?booksellerid=[% booksellerid | uri %]">Basket groups</a></li>[% END %]
        [% IF ( CAN_user_acquisition_contracts_manage ) %]<li><a href="/cgi-bin/koha/admin/aqcontract.pl?booksellerid=[% booksellerid | uri %]">Contracts</a></li>[% END %]
        <li><a href="/cgi-bin/koha/acqui/invoices.pl?supplierid=[% booksellerid | uri %]&amp;op=do_search">Invoices</a></li>
        [% IF ( CAN_user_acquisition_order_manage ) %][% IF ( basketno ) %]
        <li><a href="/cgi-bin/koha/acqui/uncertainprice.pl?booksellerid=[% booksellerid | uri %]&amp;basketno=[% basketno | uri %]&amp;owner=1">Uncertain prices</a></li>
        [% ELSE %]
        <li><a href="/cgi-bin/koha/acqui/uncertainprice.pl?booksellerid=[% booksellerid | uri %]&amp;owner=1">Uncertain prices</a></li>
        [% END %] [% END %]
    </ul>
</div>
[% END %]
