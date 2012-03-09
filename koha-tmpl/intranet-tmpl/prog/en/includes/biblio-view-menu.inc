<div id="menu">
<ul>
    [% IF ( detailview ) %]<li class="active">[% ELSE %]<li>[% END %]
    <a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=[% IF ( object ) %][% object %][% ELSE %][% biblionumber %][% END %]">Normal</a></li>

[% IF ( can_view_MARC ) %]
[% IF ( marcview ) %]<li class="active">[% ELSE %]<li>[% END %]
<a href="/cgi-bin/koha/catalogue/MARCdetail.pl?biblionumber=[% IF ( object ) %][% object %][% ELSE %][% biblionumber %][% END %]">MARC</a></li>
[% END %]

[% IF ( can_view_labeledMARC ) %]
    [% IF ( labeledmarcview ) %]<li class="active">[% ELSE %]<li>[% END %]
	<a href="/cgi-bin/koha/catalogue/labeledMARCdetail.pl?biblionumber=[% IF ( object ) %][% object %][% ELSE %][% biblionumber %][% END %]">Labeled MARC</a></li>
[% END %]

[% IF ( can_view_ISBD ) %]
    [% IF ( isbdview ) %]<li class="active">[% ELSE %]<li>[% END %]
    <a href="/cgi-bin/koha/catalogue/ISBDdetail.pl?biblionumber=[% IF ( object ) %][% object %][% ELSE %][% biblionumber %][% END %]">ISBD</a></li>
[% END %]

    [% IF ( moredetailview ) %]<li class="active">[% ELSE %]<li>[% END %]
    <a href="/cgi-bin/koha/catalogue/moredetail.pl?biblionumber=[% IF ( object ) %][% object %][% ELSE %][% biblionumber %][% END %]">Items</a></li>
    [% IF ( CAN_user_reserveforothers ) %]
    [% IF ( holdsview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/reserve/request.pl?biblionumber=[% IF ( object ) %][% object %][% ELSE %][% biblionumber %][% END %]">Holds</a></li>
    [% END %]
    [% IF ( EasyAnalyticalRecords ) %][% IF ( analyze ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=[% IF ( object ) %][% object %]&amp;analyze=1[% ELSE %][% biblionumber %]&amp;analyze=1[% END %]">Analytics</a></li>[% END %]

    [% IF ( subscriptionsnumber ) %]<li><a href="/cgi-bin/koha/serials/serials-search.pl?searched=1&amp;biblionumber=[% biblionumber %]">Subscription(s)</a></li>[% END %]
</ul>
<ul>
[% IF ( issuehistoryview ) %]<li class="active">[% ELSE %]<li>[% END %]
<a href="/cgi-bin/koha/catalogue/issuehistory.pl?biblionumber=[% IF ( object ) %][% object %][% ELSE %][% IF ( object ) %][% object %][% ELSE %][% biblionumber %][% END %][% END %]" >Checkout history</a></li>
[% IF ( CAN_user_tools_view_system_logs ) %][% IF ( logview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/tools/viewlog.pl?do_it=1&amp;modules=CATALOGUING&amp;action=MODIFY&amp;object=[% biblionumber %]">Modification log</a> </li>[% END %]
</ul>
</div>

