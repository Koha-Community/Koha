[% USE HtmlId %]
<div id="menu">
    <ul>
        [% IF ( accounting ) %]
            <li class="active">
                <a title="Accounting" href="/cgi-bin/koha/admin/preferences.pl?tab=accounting">Accounting</a>
                [% PROCESS subtabs  %]
        [% ELSE %]
            <li>
                <a title="Accounting" href="/cgi-bin/koha/admin/preferences.pl?tab=accounting">Accounting</a>
        [% END %]
        [% IF ( acquisitions ) %]
            <li class="active">
                <a title="Acquisitions" href="/cgi-bin/koha/admin/preferences.pl?tab=acquisitions">Acquisitions</a>
                [% PROCESS subtabs  %]
        [% ELSE %]
            <li>
                <a title="Acquisitions" href="/cgi-bin/koha/admin/preferences.pl?tab=acquisitions">Acquisitions</a>
        [% END %]
        </li>

        [% IF ( admin ) %]
            <li class="active">
                <a title="Administration" href="/cgi-bin/koha/admin/preferences.pl?tab=admin">Administration</a>
                [% PROCESS subtabs  %]
        [% ELSE %]
            <li>
                <a title="Administration" href="/cgi-bin/koha/admin/preferences.pl?tab=admin">Administration</a>
        [% END %]
        </li>

        [% IF ( authorities ) %]
            <li class="active">
                <a title="Authority control" href="/cgi-bin/koha/admin/preferences.pl?tab=authorities">Authorities</a>
                [% PROCESS subtabs  %]
        [% ELSE %]
            <li>
                <a title="Authority control" href="/cgi-bin/koha/admin/preferences.pl?tab=authorities">Authorities</a>
        [% END %]
        </li>

        [% IF ( cataloguing ) %]
            <li class="active">
                <a title="Cataloging" href="/cgi-bin/koha/admin/preferences.pl?tab=cataloguing">Cataloging</a>
                [% PROCESS subtabs  %]
        [% ELSE %]
            <li>
                <a title="Cataloging" href="/cgi-bin/koha/admin/preferences.pl?tab=cataloguing">Cataloging</a>
        [% END %]
        </li>

        [% IF ( circulation ) %]
            <li class="active">
                <a title="Circulation" href="/cgi-bin/koha/admin/preferences.pl?tab=circulation">Circulation</a>
                [% PROCESS subtabs  %]
        [% ELSE %]
            <li>
                <a title="Circulation" href="/cgi-bin/koha/admin/preferences.pl?tab=circulation">Circulation</a>
        [% END %]
        </li>

        [% IF ( enhanced_content ) %]
            <li class="active">
                <a title="Enhanced content settings" href="/cgi-bin/koha/admin/preferences.pl?tab=enhanced_content">Enhanced content</a>
                [% PROCESS subtabs  %]
        [% ELSE %]
            <li>
                <a title="Enhanced content settings" href="/cgi-bin/koha/admin/preferences.pl?tab=enhanced_content">Enhanced content</a>
        [% END %]
        </li>

        [% IF ( erm ) %]
            <li class="active">
                <a title="Electronic resources management" href="/cgi-bin/koha/admin/preferences.pl?tab=erm">Electronic resources management</a>
                [% PROCESS subtabs  %]
        [% ELSE %]
            <li>
                <a title="Electronic resources management" href="/cgi-bin/koha/admin/preferences.pl?tab=erm">Electronic resources management</a>
        [% END %]
        </li>

        [% IF ( i18n_l10n ) %]
            <li class="active">
                <a title="Internationalization and localization" href="/cgi-bin/koha/admin/preferences.pl?tab=i18n_l10n">I18N/L10N</a>
                [% PROCESS subtabs  %]
        [% ELSE %]
            <li>
                <a title="Internationalization and localization" href="/cgi-bin/koha/admin/preferences.pl?tab=i18n_l10n">I18N/L10N</a>
        [% END %]
        </li>

        [% IF ( local_use ) %]
            <li class="active">
                <a href="/cgi-bin/koha/admin/systempreferences.pl">Local use</a>
                [% PROCESS subtabs  %]
        [% ELSE %]
            <li>
            <a href="/cgi-bin/koha/admin/systempreferences.pl">Local use</a>
        [% END %]
        </li>

        [% IF ( logs ) %]
            <li class="active">
                <a title="Transaction logs" href="/cgi-bin/koha/admin/preferences.pl?tab=logs">Logs</a>
                [% PROCESS subtabs  %]
        [% ELSE %]
            <li>
                <a title="Transaction logs" href="/cgi-bin/koha/admin/preferences.pl?tab=logs">Logs</a>
        [% END %]
        </li>

        [% IF ( opac ) %]
            <li class="active">
                <a title="Online Public Access Catalog" href="/cgi-bin/koha/admin/preferences.pl?tab=opac">OPAC</a>
                [% PROCESS subtabs  %]
        [% ELSE %]
            <li>
                <a title="Online Public Access Catalog" href="/cgi-bin/koha/admin/preferences.pl?tab=opac">OPAC</a>
        [% END %]
        </li>

        [% IF ( patrons ) %]
            <li class="active">
                <a title="Patrons" href="/cgi-bin/koha/admin/preferences.pl?tab=patrons">Patrons</a>
                [% PROCESS subtabs  %]
        [% ELSE %]
            <li>
                <a title="Patrons" href="/cgi-bin/koha/admin/preferences.pl?tab=patrons">Patrons</a>
        [% END %]
        </li>

        [% IF ( searching ) %]
            <li class="active">
                <a title="Searching" href="/cgi-bin/koha/admin/preferences.pl?tab=searching">Searching</a>
                [% PROCESS subtabs  %]
        [% ELSE %]
            <li>
                <a title="Searching" href="/cgi-bin/koha/admin/preferences.pl?tab=searching">Searching</a>
        [% END %]
        </li>

        [% IF ( serials ) %]
            <li class="active">
                <a title="Serials" href="/cgi-bin/koha/admin/preferences.pl?tab=serials">Serials</a>
                [% PROCESS subtabs  %]
        [% ELSE %]
            <li>
                <a title="Serials" href="/cgi-bin/koha/admin/preferences.pl?tab=serials">Serials</a>
        [% END %]
        </li>

        [% IF ( staff_interface ) %]
            <li class="active">
                <a title="Staff interface" href="/cgi-bin/koha/admin/preferences.pl?tab=staff_interface">Staff interface</a>
                [% PROCESS subtabs  %]
        [% ELSE %]
            <li>
                <a title="Staff interface" href="/cgi-bin/koha/admin/preferences.pl?tab=staff_interface">Staff interface</a>
        [% END %]
        </li>

        [% IF ( tools ) %]
            <li class="active">
                <a title="Tools" href="/cgi-bin/koha/admin/preferences.pl?tab=tools">Tools</a>
                [% PROCESS subtabs  %]
        [% ELSE %]
            <li>
                <a title="Tools" href="/cgi-bin/koha/admin/preferences.pl?tab=tools">Tools</a>
        [% END %]
        </li>

        [% IF ( web_services ) %]
            <li class="active">
                <a title="Web services" href="/cgi-bin/koha/admin/preferences.pl?tab=web_services">Web services</a>
                [% PROCESS subtabs  %]
        [% ELSE %]
            <li>
                <a title="Web services" href="/cgi-bin/koha/admin/preferences.pl?tab=web_services">Web services</a>
        [% END %]
        </li>
    </ul>
</div>

[% BLOCK subtabs %]
    [% UNLESS ( searchfield ) %]
        [% FOREACH TAB IN TABS %]
            <ul>
                [% FOREACH LINE IN TAB.LINES %]
                    [% IF ( LINE.is_group_title ) %]
                        <li><a class="pref_sublink" href="#[% LINE.title | $HtmlId %]">[% LINE.title | html %]</a></li>
                    [% END %]
                [% END %]
            </ul>
        [% END %]
    [% END %]
[% END %]
