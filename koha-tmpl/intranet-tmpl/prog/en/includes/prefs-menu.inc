[% USE HtmlId %]
<div id="prefs-menu" class="sidebar_menu icon-collapse">
    <ul>
        [% IF ( accounting ) %]
            <li class="active">
                <a title="Accounting" href="/cgi-bin/koha/admin/preferences.pl?tab=accounting"><i class="fa-solid fa-coins fa-fw" aria-hidden="true"></i> <span class="menu-label">Accounting</span></a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Accounting" href="/cgi-bin/koha/admin/preferences.pl?tab=accounting"><i class="fa-solid fa-coins fa-fw" aria-hidden="true"></i> <span class="menu-label">Accounting</span></a>
            </li>
        [% END %]
        [% IF ( acquisitions ) %]
            <li class="active">
                <a title="Acquisitions" href="/cgi-bin/koha/admin/preferences.pl?tab=acquisitions"><i class="fa-solid fa-cart-shopping fa-fw" aria-hidden="true"></i> <span class="menu-label">Acquisitions</span></a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Acquisitions" href="/cgi-bin/koha/admin/preferences.pl?tab=acquisitions"><i class="fa-solid fa-cart-shopping fa-fw" aria-hidden="true"></i> <span class="menu-label">Acquisitions</span></a>
            </li>
        [% END %]

        [% IF ( admin ) %]
            <li class="active">
                <a title="Administration" href="/cgi-bin/koha/admin/preferences.pl?tab=admin"><i class="fa-solid fa-gear fa-fw" aria-hidden="true"></i> <span class="menu-label">Administration</span></a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Administration" href="/cgi-bin/koha/admin/preferences.pl?tab=admin"><i class="fa-solid fa-gear fa-fw" aria-hidden="true"></i> <span class="menu-label">Administration</span></a>
            </li>
        [% END %]

        [% IF ( authorities ) %]
            <li class="active">
                <a title="Authority control" href="/cgi-bin/koha/admin/preferences.pl?tab=authorities"><i class="fa-solid fa-address-book fa-fw" aria-hidden="true"></i> <span class="menu-label">Authorities</span></a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Authority control" href="/cgi-bin/koha/admin/preferences.pl?tab=authorities"><i class="fa-solid fa-address-book fa-fw" aria-hidden="true"></i> <span class="menu-label">Authorities</span></a>
            </li>
        [% END %]

        [% IF ( cataloguing ) %]
            <li class="active">
                <a title="Cataloging" href="/cgi-bin/koha/admin/preferences.pl?tab=cataloguing"><i class="fa-solid fa-book fa-fw" aria-hidden="true"></i> <span class="menu-label">Cataloging</span></a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Cataloging" href="/cgi-bin/koha/admin/preferences.pl?tab=cataloguing"><i class="fa-solid fa-book fa-fw" aria-hidden="true"></i> <span class="menu-label">Cataloging</span></a>
            </li>
        [% END %]

        [% IF ( circulation ) %]
            <li class="active">
                <a title="Circulation" href="/cgi-bin/koha/admin/preferences.pl?tab=circulation"><i class="fa-solid fa-arrow-right-arrow-left fa-fw" aria-hidden="true"></i> <span class="menu-label">Circulation</span></a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Circulation" href="/cgi-bin/koha/admin/preferences.pl?tab=circulation"><i class="fa-solid fa-arrow-right-arrow-left fa-fw" aria-hidden="true"></i> <span class="menu-label">Circulation</span></a>
            </li>
        [% END %]

        [% IF ( enhanced_content ) %]
            <li class="active">
                <a title="Enhanced content settings" href="/cgi-bin/koha/admin/preferences.pl?tab=enhanced_content"><i class="fa-solid fa-star fa-fw" aria-hidden="true"></i> <span class="menu-label">Enhanced content</span></a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Enhanced content settings" href="/cgi-bin/koha/admin/preferences.pl?tab=enhanced_content"><i class="fa-solid fa-star fa-fw" aria-hidden="true"></i> <span class="menu-label">Enhanced content</span></a>
            </li>
        [% END %]

        [% IF ( erm ) %]
            <li class="active">
                <a title="E-resource management" href="/cgi-bin/koha/admin/preferences.pl?tab=erm"><i class="fa-solid fa-globe fa-fw" aria-hidden="true"></i> <span class="menu-label">E-resource management</span></a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="E-resource management" href="/cgi-bin/koha/admin/preferences.pl?tab=erm"><i class="fa-solid fa-globe fa-fw" aria-hidden="true"></i> <span class="menu-label">E-resource management</span></a>
            </li>
        [% END %]

        [% IF ( i18n_l10n ) %]
            <li class="active">
                <a title="Internationalization and localization" href="/cgi-bin/koha/admin/preferences.pl?tab=i18n_l10n"><i class="fa-solid fa-language fa-fw" aria-hidden="true"></i> <span class="menu-label">I18N/L10N</span></a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Internationalization and localization" href="/cgi-bin/koha/admin/preferences.pl?tab=i18n_l10n"><i class="fa-solid fa-language fa-fw" aria-hidden="true"></i> <span class="menu-label">I18N/L10N</span></a>
            </li>
        [% END %]

        [% IF ( interlibrary_loans ) %]
            <li class="active">
                <a title="Interlibrary loans" href="/cgi-bin/koha/admin/preferences.pl?tab=interlibrary_loans"><i class="fa-solid fa-people-arrows fa-fw" aria-hidden="true"></i> <span class="menu-label">Interlibrary loans</span></a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Interlibrary loans" href="/cgi-bin/koha/admin/preferences.pl?tab=interlibrary_loans"><i class="fa-solid fa-people-arrows fa-fw" aria-hidden="true"></i> <span class="menu-label">Interlibrary loans</span></a>
            </li>
        [% END %]

        [% IF ( local_use ) %]
            <li class="active">
                <a href="/cgi-bin/koha/admin/systempreferences.pl" title="Local use"><i class="fa-solid fa-toolbox fa-fw" aria-hidden="true"></i> <span class="menu-label">Local use</span></a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a href="/cgi-bin/koha/admin/systempreferences.pl" title="Local use"><i class="fa-solid fa-toolbox fa-fw" aria-hidden="true"></i> <span class="menu-label">Local use</span></a>
            </li>
        [% END %]

        [% IF ( logs ) %]
            <li class="active">
                <a title="Transaction logs" href="/cgi-bin/koha/admin/preferences.pl?tab=logs"><i class="fa-solid fa-clipboard-list fa-fw" aria-hidden="true"></i> <span class="menu-label">Logs</span></a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Transaction logs" href="/cgi-bin/koha/admin/preferences.pl?tab=logs"><i class="fa-solid fa-clipboard-list fa-fw" aria-hidden="true"></i> <span class="menu-label">Logs</span></a>
            </li>
        [% END %]

        [% IF ( opac ) %]
            <li class="active">
                <a title="Online Public Access Catalog" href="/cgi-bin/koha/admin/preferences.pl?tab=opac"><i class="fa-solid fa-desktop fa-fw" aria-hidden="true"></i> <span class="menu-label">OPAC</span></a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Online Public Access Catalog" href="/cgi-bin/koha/admin/preferences.pl?tab=opac"><i class="fa-solid fa-desktop fa-fw" aria-hidden="true"></i> <span class="menu-label">OPAC</span></a>
            </li>
        [% END %]

        [% IF ( patrons ) %]
            <li class="active">
                <a title="Patrons" href="/cgi-bin/koha/admin/preferences.pl?tab=patrons"><i class="fa-solid fa-users fa-fw" aria-hidden="true"></i> <span class="menu-label">Patrons</span></a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Patrons" href="/cgi-bin/koha/admin/preferences.pl?tab=patrons"><i class="fa-solid fa-users fa-fw" aria-hidden="true"></i> <span class="menu-label">Patrons</span></a>
            </li>
        [% END %]

        [% IF ( preservation ) %]
            <li class="active">
                <a title="Preservation" href="/cgi-bin/koha/admin/preferences.pl?tab=preservation"><i class="fa-solid fa-recycle fa-fw" aria-hidden="true"></i> <span class="menu-label">Preservation</span></a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Preservation" href="/cgi-bin/koha/admin/preferences.pl?tab=preservation"><i class="fa-solid fa-recycle fa-fw" aria-hidden="true"></i> <span class="menu-label">Preservation</span></a>
            </li>
        [% END %]

        [% IF ( reports ) %]
            <li class="active">
                <a title="Reports" href="/cgi-bin/koha/admin/preferences.pl?tab=reports"><i class="fa-solid fa-chart-column fa-fw" aria-hidden="true"></i> <span class="menu-label">Reports</span></a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Reports" href="/cgi-bin/koha/admin/preferences.pl?tab=reports"><i class="fa-solid fa-chart-column fa-fw" aria-hidden="true"></i> <span class="menu-label">Reports</span></a>
            </li>
        [% END %]

        [% IF ( searching ) %]
            <li class="active">
                <a title="Searching" href="/cgi-bin/koha/admin/preferences.pl?tab=searching"><i class="fa-solid fa-magnifying-glass fa-fw" aria-hidden="true"></i> <span class="menu-label">Searching</span></a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Searching" href="/cgi-bin/koha/admin/preferences.pl?tab=searching"><i class="fa-solid fa-magnifying-glass fa-fw" aria-hidden="true"></i> <span class="menu-label">Searching</span></a>
            </li>
        [% END %]

        [% IF ( serials ) %]
            <li class="active">
                <a title="Serials" href="/cgi-bin/koha/admin/preferences.pl?tab=serials"><i class="fa-solid fa-newspaper fa-fw" aria-hidden="true"></i> <span class="menu-label">Serials</span></a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Serials" href="/cgi-bin/koha/admin/preferences.pl?tab=serials"><i class="fa-solid fa-newspaper fa-fw" aria-hidden="true"></i> <span class="menu-label">Serials</span></a>
            </li>
        [% END %]

        [% IF ( staff_interface ) %]
            <li class="active">
                <a title="Staff interface" href="/cgi-bin/koha/admin/preferences.pl?tab=staff_interface"><i class="fa-solid fa-user-tie fa-fw" aria-hidden="true"></i> <span class="menu-label">Staff interface</span></a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Staff interface" href="/cgi-bin/koha/admin/preferences.pl?tab=staff_interface"><i class="fa-solid fa-user-tie fa-fw" aria-hidden="true"></i> <span class="menu-label">Staff interface</span></a>
            </li>
        [% END %]

        [% IF ( tools ) %]
            <li class="active">
                <a title="Tools" href="/cgi-bin/koha/admin/preferences.pl?tab=tools"><i class="fa-solid fa-screwdriver-wrench fa-fw" aria-hidden="true"></i> <span class="menu-label">Tools</span></a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Tools" href="/cgi-bin/koha/admin/preferences.pl?tab=tools"><i class="fa-solid fa-screwdriver-wrench fa-fw" aria-hidden="true"></i> <span class="menu-label">Tools</span></a>
            </li>
        [% END %]

        [% IF ( web_services ) %]
            <li class="active">
                <a title="Web services" href="/cgi-bin/koha/admin/preferences.pl?tab=web_services"><i class="fa-solid fa-cloud fa-fw" aria-hidden="true"></i> <span class="menu-label">Web services</span></a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Web services" href="/cgi-bin/koha/admin/preferences.pl?tab=web_services"><i class="fa-solid fa-cloud fa-fw" aria-hidden="true"></i> <span class="menu-label">Web services</span></a>
            </li>
        [% END %]
    </ul>
</div>
<!-- /.sidebar_menu -->

[% BLOCK subtabs %]
    [% UNLESS ( searchfield ) %]
        [% FOREACH TAB IN TABS %]
            <ul class="pref-subtabs">
                [% FOREACH LINE IN TAB.LINES %]
                    [% IF ( LINE.is_group_title ) %]
                        <li><a class="pref_sublink" href="#[% TAB.tab_id | html %]_[% LINE.title | $HtmlId %]">[% LINE.title | html %]</a></li>
                    [% END %]
                [% END %]
            </ul>
        [% END %]
    [% END %]
[% END %]
