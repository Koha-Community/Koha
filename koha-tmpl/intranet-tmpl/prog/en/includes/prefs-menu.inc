<div id="menu">
<ul>
<!-- TMPL_IF NAME="admin" --><li class="active"><!-- TMPL_ELSE --><li><!-- /TMPL_IF --><a title="Administration" href="/cgi-bin/koha/admin/preferences.pl?tab=admin">Administration</a></li>
<!-- TMPL_IF NAME="acquisitions" --><li class="active"><!-- TMPL_ELSE --><li><!-- /TMPL_IF --><a title="Acquisitions" href="/cgi-bin/koha/admin/preferences.pl?tab=acquisitions">Acquisitions</a></li>
<!-- TMPL_IF NAME="authorities" --><li class="active"><!-- TMPL_ELSE --><li><!-- /TMPL_IF --><a title="Authority Control" href="/cgi-bin/koha/admin/preferences.pl?tab=authorities">Authorities</a></li>
<!-- TMPL_IF NAME="cataloguing" --><li class="active"><!-- TMPL_ELSE --><li><!-- /TMPL_IF --><a title="Cataloging" href="/cgi-bin/koha/admin/preferences.pl?tab=cataloguing">Cataloging</a></li>
<!-- TMPL_IF NAME="circulation" --><li class="active"><!-- TMPL_ELSE --><li><!-- /TMPL_IF --><a title="Circulation" href="/cgi-bin/koha/admin/preferences.pl?tab=circulation">Circulation</a></li>
<!-- TMPL_IF NAME="enhanced-content" --><li class="active"><!-- TMPL_ELSE --><li><!-- /TMPL_IF --><a title="Enhanced Content Settings" href="/cgi-bin/koha/admin/preferences.pl?tab=enhanced-content">Enhanced Content</a></li>
<!-- TMPL_IF NAME="i18n/l10n" --><li class="active"><!-- TMPL_ELSE --><li><!-- /TMPL_IF --><a title="Internationalization and Localization" href="/cgi-bin/koha/admin/preferences.pl?tab=i18n-l10n">I18N/L10N</a></li>
<!-- TMPL_IF NAME="logs" --><li class="active"><!-- TMPL_ELSE --><li><!-- /TMPL_IF --><a title="Transaction Logs" href="/cgi-bin/koha/admin/preferences.pl?tab=logs">Logs</a></li>
<!-- TMPL_IF NAME="oai-pmh" --><li class="active"><!-- TMPL_ELSE --><li><!-- /TMPL_IF --><a title="OAI-PMH" href="/cgi-bin/koha/admin/preferences.pl?tab=oai-pmh">OAI-PMH</a></li>
<!-- TMPL_IF NAME="opac" --><li class="active"><!-- TMPL_ELSE --><li><!-- /TMPL_IF --><a title="Online Public Access Catalog" href="/cgi-bin/koha/admin/preferences.pl?tab=opac">OPAC</a></li>
<!-- TMPL_IF NAME="patrons" --><li class="active"><!-- TMPL_ELSE --><li><!-- /TMPL_IF --><a title="Patrons" href="/cgi-bin/koha/admin/preferences.pl?tab=patrons">Patrons</a></li>
<!-- TMPL_IF NAME="searching" --><li class="active"><!-- TMPL_ELSE --><li><!-- /TMPL_IF --><a title="Searching" href="/cgi-bin/koha/admin/preferences.pl?tab=searching">Searching</a></li>
<!-- TMPL_IF NAME="staff-client" --><li class="active"><!-- TMPL_ELSE --><li><!-- /TMPL_IF --><a title="Staff Client" href="/cgi-bin/koha/admin/preferences.pl?tab=staff-client">Staff Client</a></li>
<!-- TMPL_IF NAME="" --><li class="active"><!-- TMPL_ELSE --><li><!-- /TMPL_IF --><a href="/cgi-bin/koha/admin/preferences.pl">Local Use</a></li>
</ul>
</div>
