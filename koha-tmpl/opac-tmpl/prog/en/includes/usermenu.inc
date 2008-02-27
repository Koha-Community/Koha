<!-- TMPL_IF NAME="loggedinusername" --><div id="menu">
        	<ul>
        		<li class="active"><a href="/cgi-bin/koha/opac-user.pl">my summary</a></li>
        		<li><a href="/cgi-bin/koha/opac-account.pl">my fines</a></li>
        		<li><a href="/cgi-bin/koha/opac-userupdate.pl">my personal details</a></li>
        		<!-- TMPL_IF NAME="OpacPasswordChange" --><li><a href="/cgi-bin/koha/opac-passwd.pl">change my password</a></li><!-- /TMPL_IF -->
        		<!-- TMPL_IF NAME="opacreadinghistory" --><li><a href="/cgi-bin/koha/opac-readingrecord.pl">my reading history</a></li><!-- /TMPL_IF -->
        		<!-- TMPL_IF name="suggestion" --><!-- TMPL_UNLESS NAME="AnonSuggestions" --><li><a href="/cgi-bin/koha/opac-suggestions.pl">my purchase suggestions</a></li><!-- /TMPL_UNLESS --><!-- /TMPL_IF -->
        	</ul>
</div><!-- /TMPL_IF -->
