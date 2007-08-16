<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="shortcut icon" href="<!-- TMPL_VAR NAME='themelang' -->/includes/favicon.ico" type="image/x-icon" />
<link rel="stylesheet" type="text/css" media="print" href="<!-- TMPL_VAR name="themelang" -->/includes/intranet-print.css" />
<style type="text/css" media="screen"> 
	<!-- TMPL_IF NAME="popup" -->
    @import url(<!-- TMPL_VAR NAME='themelang' -->/includes/intranet2popup.css);
	<!-- /TMPL_IF -->

	<!-- TMPL_IF NAME="login" -->
	@import url(<!-- TMPL_VAR NAME='themelang' -->/includes/login.css);
	<!-- /TMPL_IF -->

	<!-- TMPL_IF NAME="wizard" -->
    @import url(<!-- TMPL_VAR NAME='themelang' -->/includes/wizard.css);
	<!-- TMPL_ELSE -->

		<!-- TMPL_IF NAME="intranetstylesheet" -->
	@import url(<!-- TMPL_VAR NAME="intranetstylesheet" -->);
		<!-- TMPL_ELSE -->
	@import url(<!-- TMPL_VAR NAME='themelang' -->/includes/intranet2.css);
    	<!--/TMPL_IF-->    
	<!-- /TMPL_IF -->
	<!-- TMPL_IF NAME="intranetcolorstylesheet" -->
	@import url(<!-- TMPL_VAR NAME="intranetcolorstylesheet" -->);
	<!-- /TMPL_IF -->

</style>
</head>
<body>
<script language="JavaScript" type="text/javascript">
    function _(s) { return s } // dummy function for gettext
</script>
