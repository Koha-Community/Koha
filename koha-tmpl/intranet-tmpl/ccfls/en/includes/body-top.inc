<body onload="document.forms['mainform'].elements[0].focus();">

	<div id="logo">
		<img src="<!-- TMPL_VAR NAME='themelang' -->/images/logo.png" width="485" height="70" />
	</div>

	<map name="tabsMap" id="tabsMap">
		<area shape="rect" coords="812,12,930,40" href="/cgi-bin/koha/admin-home.pl" target="_self" alt="Parameters" />
		<area shape="rect" coords="681,12,799,40" href="/cgi-bin/koha/authorities/authorities-home.pl" target="_self" alt="Authorities" />
		<area shape="rect" coords="549,12,667,40" href="/cgi-bin/koha/loadmodules.pl?module=acquisitions" target="_self" alt="Aquisitions" />
		<area shape="rect" coords="277,2,399,40" href="/cgi-bin/koha/members/members-home.pl" target="_self" alt="Patrons" /><area shape="rect" coords="415,12,533,40" href="/cgi-bin/koha/reports-home.pl" target="_self" alt="Reports" />
		<area shape="rect" coords="143,2,265,40" href="/cgi-bin/koha/loadmodules.pl?module=search&amp;type=intranet" target="_self" alt="Catalog" />
		<area shape="rect" coords="8,3,130,41" href="/cgi-bin/koha/circ/circulation.pl" target="_self" alt="Circulation" />
	</map>
</div>

	<div id="issues-count">
		<img src="<!-- TMPL_VAR NAME='themelang' -->/images/issues-count.png" width="255" height="72" />
	</div>
	
	<div id="issues-count-text"><!-- TMPL_VAR NAME="branchname" --></div>
	
	<div id="logged-in-as">
		<img src="<!-- TMPL_VAR NAME='themelang' -->/images/logged-in-as.png" />
			<div id="logged-in-as-text">
				<!-- TMPL_IF NAME="loggedinusername" -->Logged in as: <br /><span class="loggedinusername"><!-- TMPL_VAR NAME="loggedinusername" --></span><!-- TMPL_ELSE -->You are not logged in!<!-- /TMPL_IF -->
			</div>
	</div>
	
	<div id="button-help">
		<aa href="/cgi-bin/koha/help.pl" onclick="Help(); return false;">
			<img src="<!-- TMPL_VAR NAME='themelang' -->/images/help.png" width="43" height="36" border="0" />
		</a>
	</div>
	
	<div id="button-about">
		<a href="/cgi-bin/koha/about.pl">
			<img src="<!-- TMPL_VAR NAME='themelang' -->/images/about.png" width="43" height="36" border="0" />
		</a>
	</div>
	
	<div id="button-logout">
		<a href="/cgi-bin/koha/mainpage.pl?logout.x=1">
			<img src="<!-- TMPL_VAR NAME='themelang' -->/images/logout.png" width="43" height="36" border="0" />
		</a>
	</div>
	
	<div id="header-background">
		<img src="<!-- TMPL_VAR NAME='themelang' -->/images/header-background.png" width="1024" height="140" />
	</div>
	
	<div id="patronSearch">
		<form action="/cgi-bin/koha/members/member.pl" method="post" name="patronSearch">
			<strong>Patron Search:</strong>
			<input id="navmember" type="text" size="20" name="member" />
			<input type="submit" value="Search" class="submit">
		</form>
	</div>
	
	<div id="catalogSearch">
		<form action="/cgi-bin/koha/search.marc/search.pl" method="post" name="catalogSearch">
			<strong>Catalog Search:</strong>
			<input type="hidden" name="op" value="do_search" />
			<input type="hidden" name="type" value="intranet" />
			<input type="hidden" name="nbstatements" value="3" />
			<input type="hidden" name="marclist" value="" />
			<input type="hidden" name="and_or" value="and" />
			<input type="hidden" name="excluding" value="" />
			<input type="hidden" name="operator" value="contains" />
			<input type="text" id="keyword" name="value" size="25" />
			<input type="submit" value="Start search" class="submit">
		</form>
	</div>
