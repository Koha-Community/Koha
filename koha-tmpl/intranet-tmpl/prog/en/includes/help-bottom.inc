<div class="action">
<form action="help.pl" method="get">
  <input type="button" class="submit" onclick="window.close(); return false;" value="Close Help Window" />
</form>
<form action="/cgi-bin/koha/edithelp.pl" method="post">
  <input type="hidden" name="type" value="modify" />
  <input type="hidden" name="referer" value="<!-- TMPL_VAR NAME="referer" -->" />
  <input type="submit" class="submit" value="Edit help" />
</form>
</div></div>
</body>
</html>
