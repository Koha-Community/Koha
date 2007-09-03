<div class="details" style="width: 43%">
<table>
<tr><th>Format :</th><td><!-- TMPL_IF NAME="active_layout_name" --><!-- TMPL_VAR NAME="active_layout_name" --><!-- TMPL_ELSE --><span class="error">Sélectionnez un format</span><!-- /TMPL_IF --> </td></tr>
<tr><th>Modèles : </th><td><!-- TMPL_IF NAME="active_template_name" --><!-- TMPL_VAR NAME="active_template_name" --><!-- TMPL_ELSE --><span class="error">Créer un modèle d'étiquette</span><!-- /TMPL_IF --> </td></tr>
<tr><th>Tâche : </th><td><!-- TMPL_IF NAME="batch_id" --><!-- TMPL_VAR NAME="batch_id" --><!-- TMPL_ELSE --><span class="error">Sélectionnez les notices à exporter</span><!-- /TMPL_IF --> </td></tr>
</table>
</div>
