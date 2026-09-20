[% USE Koha %]
<div id="guided-reports-view-menu" class="sidebar_menu icon-collapse">
    <h5>View reports</h5>
    <ul>
        [% IF ( CAN_user_reports_execute_reports_foreground || CAN_user_reports_execute_reports_background || CAN_user_reports_create_reports || CAN_user_reports_delete_own_reports || CAN_user_reports_delete_all_reports ) %]
            <li
                ><a href="/cgi-bin/koha/reports/guided_reports.pl?op=list" title="Saved reports"><i class="fa-solid fa-folder-open fa-fw" aria-hidden="true"></i> <span class="menu-label">Saved reports</span></a></li
            >
        [% END %]
    </ul>
    <h5>Reports dictionary</h5>
    <ul>
        <li
            ><a href="/cgi-bin/koha/reports/dictionary.pl" title="View dictionary"><i class="fa-solid fa-book-open fa-fw" aria-hidden="true"></i> <span class="menu-label">View dictionary</span></a></li
        >
    </ul>
    <h5>Useful resources</h5>
    <ul>
        <li
            ><a href="https://wiki.koha-community.org/wiki/SQL_Reports_Library" target="blank" title="Koha report library"><i class="fa-solid fa-book fa-fw" aria-hidden="true"></i> <span class="menu-label">Koha report library</span></a></li
        >
        [% SET koha_version = Koha.Version %]
        [% IF koha_version.development %]
            <li
                ><a href="https://schema.koha-community.org/main" target="blank" title="Koha database schema"><i class="fa-solid fa-diagram-project fa-fw" aria-hidden="true"></i> <span class="menu-label">Koha database schema</span></a></li
            >
        [% ELSE %]
            <li
                ><a href="https://schema.koha-community.org/[% koha_version.major | uri %]_[% koha_version.minor | uri %]" target="blank" title="Koha database schema"
                    ><i class="fa-solid fa-diagram-project fa-fw" aria-hidden="true"></i> <span class="menu-label">Koha database schema</span></a
                ></li
            >
        [% END %]
    </ul>
</div>
<!-- /.sidebar_menu -->
