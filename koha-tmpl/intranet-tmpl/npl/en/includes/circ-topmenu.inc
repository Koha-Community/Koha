<div id="topmenu"><a class="button" href="circulation.pl?borrnumber=<!-- TMPL_VAR name="borrowernumber" -->&amp;branch=<!-- TMPL_VAR name="branch" -->&amp;printer=<!-- TMPL_VAR name="printer" -->&amp;print=yes">
				Circulation Home</a> | <a class="button" href="returns.pl">
				Returns</a> | <a class="button" href="branchtransfers.pl">
				Transfers</a> | <form method="post" action="/cgi-bin/koha/circ/circulation.pl">
<label for="findborrower">Issue to Patron: </label>
  				<input id="findborrower" name="findborrower" type="text" size="15" />
				<input type="hidden" name="branch" value="<!-- TMPL_VAR name="branch" -->" />
				<input type="hidden" name="printer" value="<!-- TMPL_VAR name="printer" -->" />
<input type="submit" class="submit" value="Enter Patron" />
</form></div>