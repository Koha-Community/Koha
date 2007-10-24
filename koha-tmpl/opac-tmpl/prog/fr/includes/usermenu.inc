<div id="usermenu">
        <p><a href="/cgi-bin/koha/opac-user.pl">mon compte</a> <a href="/cgi-bin/koha/opac-account.pl">mes amendes</a> <a href="/cgi-bin/koha/opac-userdetails.pl">mes renseignements personnels</a>
        
        <!-- TMPL_IF NAME="OpacPasswordChange" -->
        <a href="/cgi-bin/koha/opac-passwd.pl">Modifiez votre mot de passe</a>
        <!-- /TMPL_IF -->
        
        <!-- TMPL_IF NAME="opacreadinghistory" -->
             <a href="/cgi-bin/koha/opac-readingrecord.pl">mon historique de lecture</a>
        <!-- /TMPL_IF -->
        <!-- TMPL_IF name="virtualshelves" -->
             <a href="/cgi-bin/koha/opac-shelves.pl" class="button">mes étagères virtuelles</a>
        <!-- /TMPL_IF -->
        <!-- TMPL_IF name="suggestion" -->
            <a href="/cgi-bin/koha/opac-suggestions.pl">suggestions d'achat</a>
        <!-- /TMPL_IF -->
        </p>
</div>
