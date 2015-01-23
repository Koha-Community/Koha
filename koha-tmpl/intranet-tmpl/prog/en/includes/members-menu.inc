[% IF ( borrowernumber ) %]
<div id="menu">
  <ul>
    [% IF ( circview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/circ/circulation.pl?borrowernumber=[% borrowernumber | html %]">Check out</a></li>
    [% IF ( detailview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/moremember.pl?borrowernumber=[% borrowernumber | html %]">Details</a></li>
    [% IF ( CAN_user_updatecharges ) %]
        [% IF ( finesview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/boraccount.pl?borrowernumber=[% borrowernumber | html %]">Fines</a></li>
    [% END %]
    [% IF ( intranetreadinghistory ) %]
        [% IF ( readingrecordview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/readingrec.pl?borrowernumber=[% borrowernumber | html %]">Circulation history</a></li>
    [% END %]
    [% IF ( CAN_user_parameters ) %]
        [% IF ( logview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/tools/viewlog.pl?do_it=1&amp;modules=MEMBERS&amp;action=MODIFY&amp;object=[% borrowernumber | html %]">Modification log</a></li>
    [% END %]
	[% IF ( sentnotices ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/notices.pl?borrowernumber=[% borrowernumber | html %]">Notices</a></li>
    [% IF (  statisticsview ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/statistics.pl?borrowernumber=[% borrowernumber | html %]">Statistics</a></li>
    [% IF EnableBorrowerFiles %]
        [% IF ( borrower_files ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/files.pl?borrowernumber=[% borrowernumber | html %]">Files</a></li>
    [% END %]
    [% IF CAN_user_borrowers_edit_borrowers && useDischarge %]
        [% IF dischargeview %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/discharge.pl?borrowernumber=[% borrowernumber | html %]">Discharge</a></li>
    [% END %]
    [% IF Koha.Preference('HouseboundModule') %]
        [% IF houseboundview %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/members/housebound.pl?borrowernumber=[% borrowernumber | html %]">Housebound</a></li>
    [% END %]
  </ul>
</div>
[% END %]
