<div class="dialog alert">
<script type="text/javascript">
//<![CDATA[

function confirmnotdup(){
	$("#confirm_not_duplicate").attr("value","1");
	// alert(_("Not a duplicate confirmed. Please click on Add biblio to save the record"));
	var checkform =	$("#f");
	Check(checkform);
}
//]]>
</script>


<h4>Duplicate suspected</h4>
<p>Is this a duplicate of 
	<ul><!--TMPL_LOOP Name="duplicates"-->
		<li><a href="<!--TMPL_VAR Name="url"-->?<!--TMPL_VAR Name="field_name"-->=<!-- TMPL_VAR name="dupid" -->" onclick="openWindow('<!--TMPL_VAR Name="url"-->?<!--TMPL_VAR Name="field_name"-->=<!-- TMPL_VAR name="dupid" -->&amp;popup=1', 'Duplicate '; return false;)"><!-- TMPL_VAR name="duplicateinformation" --></a>?
		<form action="<!--TMPL_VAR Name="action_dup_yes_url"-->"" method="get">
			<input type="hidden" name="<!--TMPL_VAR Name="field_name"-->" value="<!-- TMPL_VAR name="dupid" -->" />
			<input type="submit" class="edit" value="Yes: Edit existing" />
		</form>
		</li>
	<!--/TMPL_LOOP--></ul>
</p>
<form action="<!--TMPL_VAR Name="action_dup_no_url"-->" method="get">
	<input type="submit" class="save" onclick="confirmnotdup(); return false;" value="No: Save as New" />
</form>
</div>

