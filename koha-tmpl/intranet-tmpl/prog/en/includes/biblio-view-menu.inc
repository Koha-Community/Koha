[% USE Koha %]
[% USE Biblio %]
[% SET biblio_object_id = object || biblionumber || biblio.biblionumber %]

<div id="menu">
<ul>
    [% IF ( detailview ) %]<li class="active">[% ELSE %]<li>[% END %]
    <a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=[% biblio_object_id | url  %]">Normal</a></li>

[% IF ( can_view_MARC ) %]
[% IF ( marcview ) %]<li class="active">[% ELSE %]<li>[% END %]
<a href="/cgi-bin/koha/catalogue/MARCdetail.pl?biblionumber=[% biblio_object_id | url  %]">MARC</a></li>
[% END %]

[% IF ( can_view_labeledMARC ) %]
    [% IF ( labeledmarcview ) %]<li class="active">[% ELSE %]<li>[% END %]
    <a href="/cgi-bin/koha/catalogue/labeledMARCdetail.pl?biblionumber=[% biblio_object_id | url  %]">Labeled MARC</a></li>
[% END %]

[% IF ( can_view_ISBD ) %]
    [% IF ( isbdview ) %]<li class="active">[% ELSE %]<li>[% END %]
    <a href="/cgi-bin/koha/catalogue/ISBDdetail.pl?biblionumber=[% biblio_object_id | url  %]">ISBD</a></li>
[% END %]

    [% IF ( moredetailview ) %]<li class="active">[% ELSE %]<li>[% END %]
    <a href="/cgi-bin/koha/catalogue/moredetail.pl?biblionumber=[% biblio_object_id | url  %]">Items</a></li>
    [% IF ( CAN_user_reserveforothers ) %]
    [% IF ( holdsview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/reserve/request.pl?biblionumber=[% biblio_object_id | url  %]">Holds ([% Biblio.HoldsCount( biblio_object_id ) | html %])</a></li>
    [% END %]
    [% IF ( EasyAnalyticalRecords ) %][% IF ( analyze ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/catalogue/detail.pl?biblionumber=[% biblio_object_id | url  %]&amp;analyze=1">Analytics</a></li>[% END %]

    [% IF Koha.Preference('ArticleRequests') %]
        [% IF ( article_requests_view ) %]<li class="active">[% ELSE %]<li>[% END %]
        <a href="/cgi-bin/koha/circ/request-article.pl?biblionumber=[% IF ( object ) %][% object | uri %][% ELSE %][% biblionumber | uri %][% END %]">Article requests ([% Biblio.ArticleRequestsActiveCount( biblio_object_id ) | html %])</a></li>
    [% END %]

    [% IF ( subscriptionsnumber ) %]<li><a href="/cgi-bin/koha/serials/serials-search.pl?searched=1&amp;biblionumber=[% biblio_object_id | url  %]">Subscriptions ([% subscriptionsnumber | html %])</a></li>[% END %]
</ul>
<ul>
[% IF ( issuehistoryview ) %]<li class="active">[% ELSE %]<li>[% END %]
<a href="/cgi-bin/koha/catalogue/issuehistory.pl?biblionumber=[% biblio_object_id | url  %]" >Checkout history</a></li>
[% IF ( CAN_user_tools_view_system_logs ) %][% IF ( logview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/tools/viewlog.pl?do_it=1&amp;modules=CATALOGUING&amp;action=MODIFY&amp;object=[% biblio_object_id | url  %]">Modification log</a> </li>[% END %]
[% IF ( CAN_user_stockrotation_manage_rota_items && Koha.Preference('StockRotation') ) %][% IF ( stockrotationview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/catalogue/stockrotation.pl?biblionumber=[% biblio_object_id | uri %]">Rota</a> </li>[% END %]
</ul>
</div>
