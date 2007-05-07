<div id="topmenu"><a class="button" href="circulation.pl?borrnumber=<!-- TMPL_VAR name="borrowernumber" -->&amp;branch=<!-- TMPL_VAR name="branch" -->&amp;printer=<!-- TMPL_VAR name="printer" -->&amp;print=yes">
				Домівка обігу</a> | <a class="button" href="returns.pl">
				Повернення</a> | <a class="button" href="branchtransfers.pl">
				Переміщення</a> | <form method="post" action="/cgi-bin/koha/circ/circulation.pl">
<label for="findborrower-top">Issue to Patron: </label>
  				<input id="findborrower-top" name="findborrower" type="text" size="15" />
				<input type="hidden" name="branch" value="<!-- TMPL_VAR name="branch" -->" />
				<input type="hidden" name="printer" value="<!-- TMPL_VAR name="printer" -->" />
<input type="submit" class="submit" value="Ввести відвідувача">
</form></div>