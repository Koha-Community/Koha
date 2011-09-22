<h5>Build and Run Reports</h5>
<ul>
	[% IF ( CAN_user_reports_create_reports ) %]<li><a href="/cgi-bin/koha/reports/guided_reports.pl?phase=Build%20new">Build New</a></li>[% END %]
	[% IF ( CAN_user_reports_execute_reports ) %]<li><a href="/cgi-bin/koha/reports/guided_reports.pl?phase=Use%20saved">Use Saved</a></li>[% END %]
	[% IF ( CAN_user_reports_create_reports ) %]<li><a href="/cgi-bin/koha/reports/guided_reports.pl?phase=Create%20report%20from%20SQL">Create from SQL</a></li>[% END %]
</ul>
<h5>Reports Dictionary</h5>
<ul>
<li><a href="/cgi-bin/koha/reports/dictionary.pl?phase=View%20Dictionary">View Dictionary</a></li>
</ul>
<h5>Useful Resources</h5>
<ul>
<li><a href="http://wiki.koha-community.org/wiki/SQL_Reports_Library" target="blank">Koha Report Library</a></li>
<li><a href="http://schema.koha-community.org/" target="blank">Koha Database Schema</a></li>
</ul>
