<div id="usermenu">
        <p><a href="/cgi-bin/koha/opac-user.pl">my summary</a>
        <a href="/cgi-bin/koha/opac-account.pl">my fines</a>
        <a href="/cgi-bin/koha/opac-userdetails.pl">my personal details</a>
        <a href="/cgi-bin/koha/opac-passwd.pl">change my password</a>
        <!-- TMPL_IF NAME="opacreadinghistory" -->
             <a href="/cgi-bin/koha/opac-readingrecord.pl">my reading history</a>
        <!-- /TMPL_IF -->
        <!-- TMPL_IF name="virtualshelves" -->
             <a href="/cgi-bin/koha/opac-shelves.pl" class="button">my book lists</a>
        <!-- /TMPL_IF -->
        <!-- TMPL_IF name="suggestion" -->
            <a href="/cgi-bin/koha/opac-suggestions.pl">purchase suggestions</a>
        <!-- /TMPL_IF -->
        </p>
</div>