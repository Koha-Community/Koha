[% USE HtmlId %]
<div id="prefs-menu" class="sidebar_menu">
    <ul>
        [% IF ( accounting ) %]
            <li class="active">
                <a title="Accounting" href="/cgi-bin/koha/admin/preferences.pl?tab=accounting">Accounting</a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Accounting" href="/cgi-bin/koha/admin/preferences.pl?tab=accounting">Accounting</a>
            </li>
        [% END %]
        [% IF ( acquisitions ) %]
            <li class="active">
                <a title="Acquisitions" href="/cgi-bin/koha/admin/preferences.pl?tab=acquisitions">Acquisitions</a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Acquisitions" href="/cgi-bin/koha/admin/preferences.pl?tab=acquisitions">Acquisitions</a>
            </li>
        [% END %]

        [% IF ( admin ) %]
            <li class="active">
                <a title="Administration" href="/cgi-bin/koha/admin/preferences.pl?tab=admin">Administration</a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Administration" href="/cgi-bin/koha/admin/preferences.pl?tab=admin">Administration</a>
            </li>
        [% END %]

        [% IF ( authorities ) %]
            <li class="active">
                <a title="Authority control" href="/cgi-bin/koha/admin/preferences.pl?tab=authorities">Authorities</a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Authority control" href="/cgi-bin/koha/admin/preferences.pl?tab=authorities">Authorities</a>
            </li>
        [% END %]

        [% IF ( cataloguing ) %]
            <li class="active">
                <a title="Cataloging" href="/cgi-bin/koha/admin/preferences.pl?tab=cataloguing">Cataloging</a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Cataloging" href="/cgi-bin/koha/admin/preferences.pl?tab=cataloguing">Cataloging</a>
            </li>
        [% END %]

        [% IF ( circulation ) %]
            <li class="active">
                <a title="Circulation" href="/cgi-bin/koha/admin/preferences.pl?tab=circulation">Circulation</a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Circulation" href="/cgi-bin/koha/admin/preferences.pl?tab=circulation">Circulation</a>
            </li>
        [% END %]

        [% IF ( enhanced_content ) %]
            <li class="active">
                <a title="Enhanced content settings" href="/cgi-bin/koha/admin/preferences.pl?tab=enhanced_content">Enhanced content</a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Enhanced content settings" href="/cgi-bin/koha/admin/preferences.pl?tab=enhanced_content">Enhanced content</a>
            </li>
        [% END %]

        [% IF ( erm ) %]
            <li class="active">
                <a title="E-resource management" href="/cgi-bin/koha/admin/preferences.pl?tab=erm">E-resource management</a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="E-resource management" href="/cgi-bin/koha/admin/preferences.pl?tab=erm">E-resource management</a>
            </li>
        [% END %]

        [% IF ( i18n_l10n ) %]
            <li class="active">
                <a title="Internationalization and localization" href="/cgi-bin/koha/admin/preferences.pl?tab=i18n_l10n">I18N/L10N</a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Internationalization and localization" href="/cgi-bin/koha/admin/preferences.pl?tab=i18n_l10n">I18N/L10N</a>
            </li>
        [% END %]

        [% IF ( interlibrary_loans ) %]
            <li class="active">
                <a title="Interlibrary loans" href="/cgi-bin/koha/admin/preferences.pl?tab=interlibrary_loans">Interlibrary loans</a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Interlibrary loans" href="/cgi-bin/koha/admin/preferences.pl?tab=interlibrary_loans">Interlibrary loans</a>
            </li>
        [% END %]

        [% IF ( local_use ) %]
            <li class="active">
                <a href="/cgi-bin/koha/admin/systempreferences.pl">Local use</a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a href="/cgi-bin/koha/admin/systempreferences.pl">Local use</a>
            </li>
        [% END %]

        [% IF ( logs ) %]
            <li class="active">
                <a title="Transaction logs" href="/cgi-bin/koha/admin/preferences.pl?tab=logs">Logs</a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Transaction logs" href="/cgi-bin/koha/admin/preferences.pl?tab=logs">Logs</a>
            </li>
        [% END %]

        [% IF ( opac ) %]
            <li class="active">
                <a title="Online Public Access Catalog" href="/cgi-bin/koha/admin/preferences.pl?tab=opac">OPAC</a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Online Public Access Catalog" href="/cgi-bin/koha/admin/preferences.pl?tab=opac">OPAC</a>
            </li>
        [% END %]

        [% IF ( patrons ) %]
            <li class="active">
                <a title="Patrons" href="/cgi-bin/koha/admin/preferences.pl?tab=patrons">Patrons</a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Patrons" href="/cgi-bin/koha/admin/preferences.pl?tab=patrons">Patrons</a>
            </li>
        [% END %]

        [% IF ( preservation ) %]
            <li class="active">
                <a title="Preservation" href="/cgi-bin/koha/admin/preferences.pl?tab=preservation">Preservation</a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Preservation" href="/cgi-bin/koha/admin/preferences.pl?tab=preservation">Preservation</a>
            </li>
        [% END %]

        [% IF ( searching ) %]
            <li class="active">
                <a title="Searching" href="/cgi-bin/koha/admin/preferences.pl?tab=searching">Searching</a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Searching" href="/cgi-bin/koha/admin/preferences.pl?tab=searching">Searching</a>
            </li>
        [% END %]

        [% IF ( serials ) %]
            <li class="active">
                <a title="Serials" href="/cgi-bin/koha/admin/preferences.pl?tab=serials">Serials</a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Serials" href="/cgi-bin/koha/admin/preferences.pl?tab=serials">Serials</a>
            </li>
        [% END %]

        [% IF ( staff_interface ) %]
            <li class="active">
                <a title="Staff interface" href="/cgi-bin/koha/admin/preferences.pl?tab=staff_interface">Staff interface</a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Staff interface" href="/cgi-bin/koha/admin/preferences.pl?tab=staff_interface">Staff interface</a>
            </li>
        [% END %]

        [% IF ( tools ) %]
            <li class="active">
                <a title="Tools" href="/cgi-bin/koha/admin/preferences.pl?tab=tools">Tools</a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Tools" href="/cgi-bin/koha/admin/preferences.pl?tab=tools">Tools</a>
            </li>
        [% END %]

        [% IF ( web_services ) %]
            <li class="active">
                <a title="Web services" href="/cgi-bin/koha/admin/preferences.pl?tab=web_services">Web services</a>
                [% PROCESS subtabs %]
            </li>
        [% ELSE %]
            <li>
                <a title="Web services" href="/cgi-bin/koha/admin/preferences.pl?tab=web_services">Web services</a>
            </li>
        [% END %]
    </ul>
</div>
<!-- /.sidebar_menu -->

[% BLOCK subtabs %]
    [% UNLESS ( searchfield ) %]
        [% FOREACH TAB IN TABS %]
            <ul>
                [% FOREACH LINE IN TAB.LINES %]
                    [% IF ( LINE.is_group_title ) %]
                        <li><a class="pref_sublink" href="#[% TAB.tab_id | html %]_[% LINE.title | $HtmlId %]">[% LINE.title | html %]</a></li>
                    [% END %]
                [% END %]
            </ul>
        [% END %]
    [% END %]
[% END %]
