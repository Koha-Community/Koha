[% USE Koha %]
[% IF ( borrowernumber ) %]
<div class="patroninfo"><h5>[% INCLUDE 'patron-title.inc' %]</h5>
<!--[if IE 6]>
<style type="tex/css">img { width: expression(this.width > 140 ? 140: true);
}</style>
<![endif]-->
<ul class="patronbriefinfo">
    [% IF ( patronimages ) %]
        [% IF ( picture ) %]
            <li>
                <img src="/cgi-bin/koha/members/patronimage.pl?borrowernumber=[% borrowernumber | uri %]" id="patronimage" alt="[% firstname | html %] [% surname | html %] ([% cardnumber | html %])" />
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

    [% IF ( phone || mobile || phonepro ) %]<li class="patronphone">
    [% IF ( phone ) %]
        <a href="tel:[% phone | url %]">[% phone | html %]</a>
    [% ELSE %]
        [% IF ( mobile ) %]
            <a href="tel:[% mobile | url %]">[% mobile | html %]</a>
        [% ELSE %]
            [% IF ( phonepro ) %]
                <a href="tel:[% phonepro | url %]">[% phonepro | html %]</a>
            [% END %]
        [% END %]
    [% END %]</li>[% END %]
    [% IF ( email ) %]
        <li class="email"> <a href="mailto:[% email | url %]" title="[% email | html %]">[% email | html %]</a></li>
    [% ELSE %]
        [% IF ( emailpro ) %]
            <li class="email"> <a href="mailto:[% emailpro | url %]" title="[% emailpro | html %]">[% emailpro | html %]</a></li>
        [% END %]
    [% END %]

    [% UNLESS ( address or address2 ) %]
        <li><span class="empty" id="noaddressstored">No address stored.</span></li>
    [% END %]
    [% UNLESS ( city ) %]
        <li><span class="empty" id="nocitystored">No city stored.</span></li>
    [% END %]
    [% UNLESS ( phone or mobile or phonepro) %]
        <li> <span class="empty">No phone stored.</span></li>
    [% END %]
    [% UNLESS ( email or emailpro) %]
        <li> <span class="empty">No email stored.</span></li>
    [% END %]

    [% IF ( ExtendedPatronAttributes ) %][% FOREACH extendedattribute IN extendedattributes %]
        [% IF ( extendedattribute.display_checkout ) %]
            [% IF ( extendedattribute.value ) %]
                <li class="patronattribute"><span class="patronattributelabel">[% extendedattribute.description %]</span> : [% IF ( extendedattribute.value_description ) %][% extendedattribute.value_description %][% ELSE %][% extendedattribute.value %][% END %]</li>
            [% END %]
        [% END %]
    [% END %][% END %]
    <li class="patroncategory">Category: [% categoryname %] ([% categorycode %])</li>
    <li class="patronlibrary">Home library: [% Branches.GetName( branchcode ) %]</li>
</ul></div>
<div id="menu">
<ul>
    [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
        [% IF ( circview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/circ/circulation.pl?borrowernumber=[% borrowernumber %]">Check out</a></li>
        [% IF Koha.Preference('BatchCheckouts') && Koha.Preference('BatchCheckoutsValidCategories').split('\|').grep('^' _ categorycode _ '$').size > 0 %]
          [% IF ( batch_checkout_view ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/circ/circulation.pl?borrowernumber=[% borrowernumber %]&amp;batch=1">Batch check out</a></li>
        [% END %]
    [% END %]
    [% IF ( CAN_user_borrowers ) %]
        [% IF ( detailview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/moremember.pl?borrowernumber=[% borrowernumber %]">Details</a></li>
    [% END %]
    [% IF ( CAN_user_updatecharges ) %]
        [% IF ( finesview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/pay.pl?borrowernumber=[% borrowernumber %]">Fines</a></li>
    [% END %]
    [% IF ( CAN_user_circulate_circulate_remaining_permissions  )  %]
        [% IF Koha.Preference("RoutingSerials") %][% IF ( routinglistview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/routing-lists.pl?borrowernumber=[% borrowernumber %]">Routing lists</a></li>[% END %]
    [% END %]
    [% IF ( CAN_user_borrowers ) %]
        [% IF ( intranetreadinghistory ) %]
            [% IF ( readingrecordview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/readingrec.pl?borrowernumber=[% borrowernumber %]">Circulation history</a></li>
        [% END %]
    [% END %]
    [% IF ( CAN_user_borrowers ) %]
        [% IF ( intranetreadinghistory ) %]
            [% IF ( holdshistoryview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/holdshistory.pl?borrowernumber=[% borrowernumber %]">Holds history</a></li>
        [% END %]
    [% END %]
    [% IF ( CAN_user_parameters ) %]
        [% IF ( logview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/tools/viewlog.pl?do_it=1&amp;modules=MEMBERS&amp;modules=circulation&amp;object=[% borrowernumber %]&amp;src=circ">Modification log</a></li>
    [% END %]
    [% IF ( CAN_user_borrowers ) %]
	[% IF ( sentnotices ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/notices.pl?borrowernumber=[% borrowernumber %]">Notices</a></li>
    [% END %]
    [% IF ( CAN_user_borrowers ) %]
        [% IF (  statisticsview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/statistics.pl?borrowernumber=[% borrowernumber %]">Statistics</a></li>
    [% END %]
    [% IF ( CAN_user_borrowers ) %]
        [% IF ( EnableBorrowerFiles ) %]
            [% IF ( borrower_files ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/files.pl?borrowernumber=[% borrowernumber %]">Files</a></li>
        [% END %]
    [% END %]

    [% IF ( CAN_user_borrowers ) %]
        [% IF ( suggestionsview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/purchase-suggestions.pl?borrowernumber=[% borrowernumber %]">Purchase suggestions</a></li>
    [% END %]
    [% IF CAN_user_borrowers && useDischarge %]
        [% IF dischargeview %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/discharge.pl?borrowernumber=[% borrowernumber %]">Discharges</a></li>
    [% END %]
    [% IF Koha.Preference('HouseboundModule') %]
        [% IF houseboundview %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/housebound.pl?borrowernumber=[% borrowernumber %]">Housebound</a></li>
    [% END %]
    [% IF Koha.Preference('ILLModule') %]
        <li><a href="/cgi-bin/koha/ill/ill-requests.pl?borrowernumber=[% borrowernumber %]">Interlibrary loans</a></li>
    [% END %]
</ul></div>
[% END %]
