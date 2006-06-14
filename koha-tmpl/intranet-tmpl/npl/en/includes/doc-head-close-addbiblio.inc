</title>
<!-- TMPL_IF NAME="TemplateEncoding" -->
<meta http-equiv="Content-Type" content="text/html; charset=<!-- TMPL_VAR NAME='TemplateEncoding' -->" />
<!-- TMPL_ELSE -->
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<!-- /TMPL_IF -->
<link rel="shortcut icon" href="<!-- TMPL_VAR NAME='themelang' -->/includes/favicon.ico" type="image/x-icon" />
<style type="text/css">
        <!-- TMPL_IF NAME="intranetstylesheet" -->@import url(<!-- TMPL_VAR NAME='themelang' -->/includes/<!-- TMPL_VAR NAME="intranetstylesheet" -->);<!-- TMPL_ELSE -->@import url(<!-- TMPL_VAR NAME='themelang' -->/includes/intranet.css);<!-- /TMPL_IF -->
	<!-- TMPL_IF NAME="intranetcolorstylesheet" -->@import url(<!-- TMPL_VAR NAME='themelang' -->/includes/<!-- TMPL_VAR NAME="intranetcolorstylesheet" -->);<!-- /TMPL_IF -->
</style>
<!-- TMPL_INCLUDE NAME="common.js.inc" -->
</head>

<body onload="loading();">
