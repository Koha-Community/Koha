<div id="usermenu">
        	<ul>
        		<li><a href="/cgi-bin/koha/opac-user.pl">my summary</a></li>
        		<li><a href="/cgi-bin/koha/opac-account.pl">my fines</a></li>
        		<li><a href="/cgi-bin/koha/opac-userdetails.pl">my personal details</a></li>
        		<li><!-- TMPL_IF NAME="OpacPasswordChange" --><a href="/cgi-bin/koha/opac-passwd.pl">change my password</a><!-- /TMPL_IF --></li>
        		<li><!-- TMPL_IF NAME="opacreadinghistory" --><a href="/cgi-bin/koha/opac-readingrecord.pl">my reading history</a><!-- /TMPL_IF --></li>
        		<li><!-- TMPL_IF name="virtualshelves" --><a href="/cgi-bin/koha/opac-shelves.pl" class="button">my book lists</a><!-- /TMPL_IF --></li>
        		<li><!-- TMPL_IF name="suggestion" --><a href="/cgi-bin/koha/opac-suggestions.pl">purchase suggestions</a><!-- /TMPL_IF --></li>
        	</ul>
</div>
