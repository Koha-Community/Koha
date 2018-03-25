[% USE Koha %]
[% IF ( patron.borrowernumber ) %]
<div class="patroninfo"><h5>[% INCLUDE 'patron-title.inc' %]</h5>
<!--[if IE 6]>
<style type="tex/css">img { width: expression(this.width > 140 ? 140: true);
}</style>
<![endif]-->
<ul class="patronbriefinfo">
    [% IF ( patronimages ) %]
        [% IF ( patron.image ) %]
            <li>
                <img src="/cgi-bin/koha/members/patronimage.pl?borrowernumber=[% patron.borrowernumber | uri %]" id="patronimage" alt="[% patron.firstname | html %] [% patron.surname | html %] ([% patron.cardnumber | html %])" />
            </li>
        [% ELSE %]
            <li id="patronbasics">
                <div></div>
            </li>
        [% END %]
    [% END %]
    [% IF Koha.Preference( 'AddressFormat' ) %]
        [% INCLUDE "member-display-address-style-${ Koha.Preference( 'AddressFormat' ) }.inc" %]
    [% ELSE %]
        [% INCLUDE 'member-display-address-style-us.inc' %]
    [% END %]

    [% IF ( patron.phone || patron.mobile || patron.phonepro ) %]<li class="patronphone">
    [% IF ( patron.phone ) %]
        <a href="tel:[% patron.phone | url %]">[% patron.phone | html %]</a>
    [% ELSE %]
        [% IF ( patron.mobile ) %]
            <a href="tel:[% patron.mobile | url %]">[% patron.mobile | html %]</a>
        [% ELSE %]
            [% IF ( patron.phonepro ) %]
                <a href="tel:[% patron.phonepro | url %]">[% patron.phonepro | html %]</a>
            [% END %]
        [% END %]
    [% END %]</li>[% END %]
    [% IF ( patron.email ) %]
        <li class="email"> <a href="mailto:[% patron.email | url %]" title="[% patron.email | html %]">[% patron.email | html %]</a></li>
    [% ELSE %]
        [% IF ( patron.emailpro ) %]
            <li class="email"> <a href="mailto:[% patron.emailpro | url %]" title="[% patron.emailpro | html %]">[% patron.emailpro | html %]</a></li>
        [% END %]
    [% END %]

    [% UNLESS ( patron.address or patron.address2 ) %]
        <li><span class="empty" id="noaddressstored">No address stored.</span></li>
    [% END %]
    [% UNLESS ( patron.city ) %]
        <li><span class="empty" id="nocitystored">No city stored.</span></li>
    [% END %]
    [% UNLESS ( patron.phone or patron.mobile or patron.phonepro) %]
        <li> <span class="empty">No phone stored.</span></li>
    [% END %]
    [% UNLESS ( patron.email or patron.emailpro) %]
        <li> <span class="empty">No email stored.</span></li>
    [% END %]

    [% IF ( ExtendedPatronAttributes ) %][% FOREACH extendedattribute IN extendedattributes %]
        [% IF ( extendedattribute.display_checkout ) %]
            [% IF ( extendedattribute.value ) %]
                <li class="patronattribute"><span class="patronattributelabel">[% extendedattribute.description %]</span> : [% IF ( extendedattribute.value_description ) %][% extendedattribute.value_description %][% ELSE %][% extendedattribute.value %][% END %]</li>
            [% END %]
        [% END %]
    [% END %][% END %]
    <li class="patroncategory">Category: [% patron.category.description %] ([% patron.categorycode %])</li>
    <li class="patronlibrary">Home library: [% Branches.GetName( patron.branchcode ) %]</li>
    <li class="patronborrowernumber">Borrowernumber: [% patron.borrowernumber %]</li>
  </ul></div>
<div id="menu">
<ul>
    [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
        [% IF ( circview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/circ/circulation.pl?borrowernumber=[% patron.borrowernumber %]">Check out</a></li>
        [% IF Koha.Preference('BatchCheckouts') && Koha.Preference('BatchCheckoutsValidCategories').split('\|').grep('^' _ patron.categorycode _ '$').size > 0 %]
          [% IF ( batch_checkout_view ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/circ/circulation.pl?borrowernumber=[% patron.borrowernumber %]&amp;batch=1">Batch check out</a></li>
        [% END %]
    [% END %]
    [% IF CAN_user_borrowers_edit_borrowers %]
        [% IF ( detailview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/moremember.pl?borrowernumber=[% patron.borrowernumber %]">Details</a></li>
    [% END %]
    [% IF ( CAN_user_updatecharges ) %]
        [% IF ( finesview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/pay.pl?borrowernumber=[% patron.borrowernumber %]">Fines</a></li>
    [% END %]
    [% IF ( CAN_user_circulate_circulate_remaining_permissions  )  %]
        [% IF Koha.Preference("RoutingSerials") %][% IF ( routinglistview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/routing-lists.pl?borrowernumber=[% patron.borrowernumber %]">Routing lists</a></li>[% END %]
    [% END %]
    [% IF CAN_user_borrowers_edit_borrowers %]
        [% IF ( intranetreadinghistory ) %]
            [% IF ( readingrecordview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/readingrec.pl?borrowernumber=[% patron.borrowernumber %]">Circulation history</a></li>
        [% END %]
    [% END %]
    [% IF CAN_user_borrowers_edit_borrowers %]
        [% IF ( intranetreadinghistory ) %]
            [% IF ( holdshistoryview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/holdshistory.pl?borrowernumber=[% patron.borrowernumber %]">Holds history</a></li>
        [% END %]
    [% END %]
    [% IF ( CAN_user_parameters ) %]
        [% IF ( logview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/tools/viewlog.pl?do_it=1&amp;modules=MEMBERS&amp;modules=circulation&amp;object=[% patron.borrowernumber %]&amp;src=circ">Modification log</a></li>
    [% END %]
    [% IF CAN_user_borrowers_edit_borrowers %]
    [% IF ( sentnotices ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/notices.pl?borrowernumber=[% patron.borrowernumber %]">Notices</a></li>
    [% END %]
    [% IF CAN_user_borrowers_edit_borrowers %]
        [% IF (  statisticsview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/statistics.pl?borrowernumber=[% patron.borrowernumber %]">Statistics</a></li>
    [% END %]
    [% IF CAN_user_borrowers_edit_borrowers %]
        [% IF ( EnableBorrowerFiles ) %]
            [% IF ( borrower_files ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/files.pl?borrowernumber=[% patron.borrowernumber %]">Files</a></li>
        [% END %]
    [% END %]

    [% IF CAN_user_borrowers_edit_borrowers %]
        [% IF ( suggestionsview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/purchase-suggestions.pl?borrowernumber=[% patron.borrowernumber %]">Purchase suggestions</a></li>
    [% END %]
    [% IF CAN_user_borrowers_edit_borrowers && useDischarge %]
        [% IF dischargeview %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/discharge.pl?borrowernumber=[% patron.borrowernumber %]">Discharges</a></li>
    [% END %]
    [% IF Koha.Preference('HouseboundModule') %]
        [% IF houseboundview %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/housebound.pl?borrowernumber=[% patron.borrowernumber %]">Housebound</a></li>
    [% END %]
    [% IF Koha.Preference('ILLModule') %]
        <li><a href="/cgi-bin/koha/ill/ill-requests.pl?borrowernumber=[% patron.borrowernumber %]">Interlibrary loans</a></li>
    [% END %]
</ul></div>
[% END %]
