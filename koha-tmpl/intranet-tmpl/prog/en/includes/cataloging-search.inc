<script>$(document).ready(function(){
	$("input[name=q]:eq(0)").focus();
});</script>

<h1 id="logo"><a href="/cgi-bin/koha/mainpage.pl">[% LibraryName %]</a></h1><!-- Begin Cataloging Resident Search Box -->
<div id="header_search">
<div id="addbooks_search" class="residentsearch">
	<p class="tip">Search the catalog and the reservoir:</p>
	<form name="search" action="addbooks.pl">
        <input type="text" name="q" size="40" />
        <input type="submit" class="submit" value="Submit" />
	</form>
</div>
    [% INCLUDE 'patron-search-box.inc' %]
			<ul>
            <li><a href="/cgi-bin/koha/catalogue/search.pl#addbooks_search">Cataloging search</a></li>
            [% IF ( CAN_user_circulate ) %]<li><a href="/cgi-bin/koha/circ/circulation.pl#circ_search">Check out</a></li>[% END %]
			</ul>	
</div>
<!-- End Cataloging Resident Search Box -->
