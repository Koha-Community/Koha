<TMPL_IF NAME="loggedinuser">
<TMPL_ELSE>
	<form>
	<div class="main">Members can sign in here:
	<br />Cardnumber:
	<br /><input type="text" name="name" size="18" />
	<br />Password:
	<br /><input type="text" name="password" size="18" />&nbsp;&nbsp;<input type="image" name="Go" src="<TMPL_VAR NAME='themelang'>/images/styles/home-go-button.gif" alt="Go" align="absmiddle" border="0" /></div>
	</form>
</TMPL_IF>