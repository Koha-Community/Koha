<div class="details" style="width: 43%">
<table>
<tr><th>Layout:</th><td><!-- TMPL_IF NAME="active_layout_name" --><!-- TMPL_VAR NAME="active_layout_name" --><!-- TMPL_ELSE --><span class="error">No Layout Specified: Select a Label Layout</span><!-- /TMPL_IF --> </td></tr>
<tr><th>Template: </th><td><!-- TMPL_IF NAME="active_template_name" --><!-- TMPL_VAR NAME="active_template_name" --><!-- TMPL_ELSE --><span class="error">No Template Specified: Select a Label Template</span><!-- /TMPL_IF --> </td></tr>
<tr><th>Batch: </th><td><!-- TMPL_IF NAME="batch_id" --><!-- TMPL_VAR NAME="batch_id" --><!-- TMPL_ELSE --><span class="error">No Batch Specified: Select items to print</span><!-- /TMPL_IF --> </td></tr>
</table>
</div>
