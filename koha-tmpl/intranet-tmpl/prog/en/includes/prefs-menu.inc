<div id="menu">
<ul>
[% IF ( acquisitions ) %]<li class="active">[% ELSE %]<li>[% END %]<a title="Acquisitions" href="/cgi-bin/koha/admin/preferences.pl?tab=acquisitions">Acquisitions</a></li>
[% IF ( admin ) %]<li class="active">[% ELSE %]<li>[% END %]<a title="Administration" href="/cgi-bin/koha/admin/preferences.pl?tab=admin">Administration</a></li>
[% IF ( authorities ) %]<li class="active">[% ELSE %]<li>[% END %]<a title="Authority Control" href="/cgi-bin/koha/admin/preferences.pl?tab=authorities">Authorities</a></li>
[% IF ( cataloguing ) %]<li class="active">[% ELSE %]<li>[% END %]<a title="Cataloging" href="/cgi-bin/koha/admin/preferences.pl?tab=cataloguing">Cataloging</a></li>
[% IF ( circulation ) %]<li class="active">[% ELSE %]<li>[% END %]<a title="Circulation" href="/cgi-bin/koha/admin/preferences.pl?tab=circulation">Circulation</a></li>
[% IF ( enhanced_content ) %]<li class="active">[% ELSE %]<li>[% END %]<a title="Enhanced content settings" href="/cgi-bin/koha/admin/preferences.pl?tab=enhanced_content">Enhanced content</a></li>
[% IF ( i18n_l10n ) %]<li class="active">[% ELSE %]<li>[% END %]<a title="Internationalization and localization" href="/cgi-bin/koha/admin/preferences.pl?tab=i18n_l10n">I18N/L10N</a></li>
[% IF ( local_use ) %]<li class="active">[% ELSE %]<li>[% END %]<a href="/cgi-bin/koha/admin/systempreferences.pl">Local use</a></li>
[% IF ( logs ) %]<li class="active">[% ELSE %]<li>[% END %]<a title="Transaction logs" href="/cgi-bin/koha/admin/preferences.pl?tab=logs">Logs</a></li>
[% IF ( opac ) %]<li class="active">[% ELSE %]<li>[% END %]<a title="Online Public Access Catalog" href="/cgi-bin/koha/admin/preferences.pl?tab=opac">OPAC</a></li>
[% IF ( patrons ) %]<li class="active">[% ELSE %]<li>[% END %]<a title="Patrons" href="/cgi-bin/koha/admin/preferences.pl?tab=patrons">Patrons</a></li>
[% IF ( searching ) %]<li class="active">[% ELSE %]<li>[% END %]<a title="Searching" href="/cgi-bin/koha/admin/preferences.pl?tab=searching">Searching</a></li>
[% IF ( serials ) %]<li class="active">[% ELSE %]<li>[% END %]<a title="Serials" href="/cgi-bin/koha/admin/preferences.pl?tab=serials">Serials</a></li>
[% IF ( staff_client ) %]<li class="active">[% ELSE %]<li>[% END %]<a title="Staff client" href="/cgi-bin/koha/admin/preferences.pl?tab=staff_client">Staff client</a></li>
[% IF ( tools ) %]<li class="active">[% ELSE %]<li>[% END %]<a title="Tools" href="/cgi-bin/koha/admin/preferences.pl?tab=tools">Tools</a></li>
[% IF ( web_services ) %]<li class="active">[% ELSE %]<li>[% END %]<a title="Web services" href="/cgi-bin/koha/admin/preferences.pl?tab=web_services">Web services</a></li>
</ul>
</div>
