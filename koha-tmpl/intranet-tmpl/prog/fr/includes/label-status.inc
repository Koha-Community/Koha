<div class="details" style="width: 43%">
<table>
<tr><th>Format :</th><td><!-- TMPL_IF NAME="active_layout_name" --><!-- TMPL_VAR NAME="active_layout_name" --><!-- TMPL_ELSE --><span class="error">Pas de modèle défini : <a href="/cgi-bin/koha/labels/label-home.pl">Sélectionner un modèle</a></span><!-- /TMPL_IF --> </td></tr>
<tr><th>Modèles : </th><td><!-- TMPL_IF NAME="active_template_name" --><!-- TMPL_VAR NAME="active_template_name" --><!-- TMPL_ELSE --><span class="error">Pas de modèle défini <a href="/cgi-bin/koha/labels/label-templates.pl">Sélectionner un modèle d'étiquette</a></span><!-- /TMPL_IF --> </td></tr>
<tr><th>Tâche : </th><td><!-- TMPL_IF NAME="batch_id" --><!-- TMPL_VAR NAME="batch_id" --><!-- TMPL_ELSE --><span class="error">Pas de traitement spécifié <a href="/cgi-bin/koha/labels/label-manager.pl">Sélectionnez les exemplaires à imprimer</a></span><!-- /TMPL_IF --> </td></tr>
</table>
</div>
