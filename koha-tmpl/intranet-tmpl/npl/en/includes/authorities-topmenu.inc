<div id="topmenu">
<form class="inline" name="f" action="/cgi-bin/koha/authorities/authorities-home.pl" method="post">
	<input type="hidden" name="op" value="do_search" />
	<input type="hidden" name="type" value="intranet" />
	<input type="hidden" name="nbstatements" value="<!-- TMPL_VAR NAME="nbstatements" -->"> <select name="authtypecode" />
			<!-- TMPL_LOOP NAME="authtypesloop" -->
			<!-- TMPL_IF name="selected" --><option value="<!-- TMPL_VAR NAME="value" -->" selected="selected"><!-- TMPL_ELSE --><option value="<!-- TMPL_VAR NAME="value" -->"><!-- /TMPL_IF --><!-- TMPL_VAR NAME="authtypetext" --></option>
			
			<!-- /TMPL_LOOP -->
			</select> <input type="hidden" name="marclist" value="" />
			<input type="hidden" name="and_or" value="and" />
			<input type="hidden" name="excluding" value=""> <input type="hidden" name="operator" value="contains" /> <input type="text" id="anywhere" size="10" name="value" value="<!-- TMPL_VAR NAME="value" -->" /> <input type="submit" value="Search" class="submit" /></form>

<form name="f2" method="post" action="authorities.pl"><select name="authtypecode" id="authtypecode"><!-- TMPL_LOOP name="authtypesloop" --><!-- TMPL_IF name="selected" --><option value="<!-- TMPL_VAR name="value" -->" selected="selected"><!-- TMPL_ELSE --><option value="<!-- TMPL_VAR name="value" -->"><!-- /TMPL_IF --><!-- TMPL_VAR name="authtypetext" --></option><!-- /TMPL_LOOP --></select> <input type="submit" value="Add" class="submit"></form>
</div>
