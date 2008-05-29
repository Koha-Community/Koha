<div style="margin-top: 1em;">
<h3>Active  Settings</h3>
<table>
<tr><th>Layout:</th><td><!-- TMPL_IF NAME="active_layout_name" --><!-- TMPL_VAR NAME="active_layout_name" --><!-- TMPL_ELSE --><span class="error">No Layout Specified: <a href="/cgi-bin/koha/labels/label-home.pl">Select a Label Layout</a></span><!-- /TMPL_IF --> </td></tr>
<tr><th>Template: </th><td><!-- TMPL_IF NAME="active_template_name" --><!-- TMPL_VAR NAME="active_template_name" --><!-- TMPL_ELSE --><span class="error">No Template Specified: <a href="/cgi-bin/koha/labels/label-templates.pl">Select a Label Template</a></span><!-- /TMPL_IF --> </td></tr>
<tr><th>Batch: </th><td><!-- TMPL_IF NAME="batch_id" --><!-- TMPL_VAR NAME="batch_id" --><!-- TMPL_ELSE --><span class="error"><a href="/cgi-bin/koha/labels/label-manager.pl?op=add_batch&amp;type=<!-- TMPL_VAR NAME="batch_type" -->">Create a new batch</a></span><!-- /TMPL_IF --> </td></tr>
</table>
</div>
