<div id="toolbar">

  <form name="f2" method="post" action="authorities.pl">
	<label for="add_authtypecode">Nouveau : </label>
        <select id="add_authtypecode" name="authtypecode">
<!-- TMPL_LOOP name="authtypesloop" -->
  <!-- TMPL_IF name="selected" -->
        <option value="<!-- TMPL_VAR name="value" -->" selected="selected"><!-- TMPL_VAR name="authtypetext" --></option>
  <!-- TMPL_ELSE -->
        <option value="<!-- TMPL_VAR name="value" -->"><!-- TMPL_VAR name="authtypetext" --></option>
  <!-- /TMPL_IF -->
<!-- /TMPL_LOOP -->
        </select>
      <input type="submit" value="Ajouter" class="button">
  </form>
</div>