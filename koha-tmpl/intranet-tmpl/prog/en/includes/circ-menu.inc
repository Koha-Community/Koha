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
            <li><img src="/cgi-bin/koha/members/patronimage.pl?borrowernumber=[% borrowernumber | uri %]" id="patronimage" alt="[% firstname %] [% surname %] ([% cardnumber %])" border="0" style="max-width : 140px; margin: .3em 0 .3em .3em; padding: .2em; border: 1px solid #CCCCCC; width:auto !important; width:130px;" /></li>
        [% ELSE %]
            <li id="patronbasics"><img src="[% interface %]/[% theme %]/img/patron-blank.png" alt="[% firstname %] [% surname %] ([% cardnumber %])" border="0" style="margin: .3em 0 .3em .3em; padding: .2em; border: 1px solid #CCCCCC;" /></li>
        [% END %]
    [% END %]
    [% IF Koha.Preference( 'AddressFormat' ) %]
        [% INCLUDE "member-display-address-style-${ Koha.Preference( 'AddressFormat' ) }.inc" %]
    [% ELSE %]
        [% INCLUDE 'member-display-address-style-us.inc' %]
    [% END %]

    [% IF ( phone ) %]<li class="patronphone">
        <a href="tel:[% phone %]">[% phone %]</a>
    [% ELSE %]
        [% IF ( mobile ) %]
            <a href="tel:[% mobile %]">[% mobile %]</a>
        [% ELSE %]
            [% IF ( phonepro ) %]
                <a href="tel:[% phonepro %]">[% phonepro %]</a>
            [% END %]
        [% END %]</li>
    [% END %]
    [% IF ( email ) %]
        <li class="email"> <a href="mailto:[% email %]" title="[% email %]">[% email %]</a></li>
    [% ELSE %]
        [% IF ( emailpro ) %]
            <li class="email"> <a href="mailto:[% emailpro %]" title="[% emailpro %]">[% emailpro %]</a></li>
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
    <li class="patronlibrary">Home library: [% IF ( branchname ) %][% branchname %][% ELSE %][% branch %][% END %]</li>
</ul></div>
<div id="menu">
<ul>
    [% IF ( CAN_user_circulate_circulate_remaining_permissions ) %]
        [% IF ( circview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/circ/circulation.pl?borrowernumber=[% borrowernumber %]">Check out</a></li>
        [% IF Koha.Preference('BatchCheckouts') &&
              Koha.Preference('BatchCheckoutsValidCategories').split('\|').grep('^' _ categorycode _ '$').size > 0 %]
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
        [% IF ( RoutingSerials ) %][% IF ( routinglistview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/routing-lists.pl?borrowernumber=[% borrowernumber %]">Routing lists</a></li>[% END %]
    [% END %]
    [% IF ( CAN_user_borrowers ) %]
        [% IF ( intranetreadinghistory ) %]
            [% IF ( readingrecordview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/readingrec.pl?borrowernumber=[% borrowernumber %]">Circulation history</a></li>
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
        [% IF dischargeview %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/discharge.pl?borrowernumber=[% borrowernumber %]">Discharge</a></li>
    [% END %]
</ul></div>
[% END %]
