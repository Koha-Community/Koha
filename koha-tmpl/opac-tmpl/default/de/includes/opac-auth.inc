<!-- Anmeldestatus -->

   <TMPL_IF NAME="loggedinuser">
       <p align=left>Angemeldet als: <TMPL_VAR NAME="loggedinuser"> [<a href=/cgi-bin/koha/opac-user.pl>Mitgliederbereich</a>][<a href=/cgi-bin/koha/opac-main.pl?logout.x=1>Abmelden</a>]</p>
   <TMPL_ELSE>
       <p align=left><a href=/cgi-bin/koha/opac-user.pl>Anmelden</a> bei Koha</p>
   </TMPL_IF>

