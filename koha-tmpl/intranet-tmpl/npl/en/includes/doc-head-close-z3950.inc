</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<!-- TMPL_IF name="refresh" --><meta http-equiv="refresh" content="2; url=<!-- TMPL_VAR NAME="refresh" -->" /><!-- /TMPL_IF -->
<link rel="shortcut icon" href="<!-- TMPL_VAR NAME='themelang' -->/includes/favicon.ico" type="image/x-icon" />
<style type="text/css"> 
	@import url(<!-- TMPL_VAR NAME="themelang" -->/includes/intranet.css);
	#main {
		background-color : #CCCC99;
		border-left : 1px solid #CCCC99;
		margin-left : 2%;
		margin-right : 2%;
		margin-top : 2%;
		padding : 10px;
		position : relative;
	}
</style>
<script language="JavaScript" type="text/javascript">
	function Import(GetThisOne) {
		opener.document.location= "../acqui.simple/addbiblio.pl?z3950=1&oldbiblionumber=<!-- TMPL_VAR NAME="oldbiblionumber" -->&breedingid="+GetThisOne;
		self.close();
		return false;
	}
</script>