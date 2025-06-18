[% USE Koha %]
<div id="guided-reports-view-menu" class="sidebar_menu">
    <h5>Run reports</h5>
    <ul>
        [% IF ( CAN_user_reports_execute_reports ) %]<li><a href="/cgi-bin/koha/reports/guided_reports.pl?op=list">Saved reports</a></li>[% END %]
    </ul>
    <h5>Reports dictionary</h5>
    <ul>
        <li><a href="/cgi-bin/koha/reports/dictionary.pl">View dictionary</a></li>
    </ul>
    <h5>Useful resources</h5>
    <ul>
        <li><a href="https://wiki.koha-community.org/wiki/SQL_Reports_Library" target="blank">Koha report library</a></li>
        [% SET koha_version = Koha.Version %]
        [% IF koha_version.development %]
            <li><a href="https://schema.koha-community.org/main" target="blank">Koha database schema</a></li>
        [% ELSE %]
            <li><a href="https://schema.koha-community.org/[% koha_version.major | uri %]_[% koha_version.minor | uri %]" target="blank">Koha database schema</a></li>
        [% END %]
    </ul>
</div>
<!-- /.sidebar_menu -->
