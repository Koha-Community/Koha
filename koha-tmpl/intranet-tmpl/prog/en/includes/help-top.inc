<!-- TMPL_INCLUDE NAME="doc-head-open.inc" -->
<title>Online Help</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="shortcut icon" href="<!-- TMPL_VAR NAME="themelang" -->/includes/favicon.ico" type="image/x-icon" />
<link rel="stylesheet" type="text/css" media="print" href="<!-- TMPL_VAR name="themelang" -->/css/print.css" />
<!-- TMPL_IF name="intranetstylesheet" -->
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="intranetstylesheet" -->" />
<!-- TMPL_ELSE -->
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/css/staff-global.css" />
<!-- /TMPL_IF -->
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/lib/jquery/jquery.js"></script>
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/lib/jquery/plugins/ui.tabs.js"></script>
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/lib/jquery/plugins/jquery.hotkeys.min.js"></script>
<!-- local colors -->
<!-- TMPL_IF name="intranetcolorstylesheet" -->
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/css/<!-- TMPL_VAR NAME="intranetcolorstylesheet" -->" />
<!-- /TMPL_IF -->
<!-- yui js --> 
<script type="text/javascript" src="<!-- TMPL_VAR NAME="yuipath" -->/utilities/utilities.js"></script> 
<!-- TMPL_IF NAME="CircAutocompl" --><script type="text/javascript" src="<!-- TMPL_VAR NAME="yuipath" -->/autocomplete/autocomplete-min.js"></script> <!-- /TMPL_IF -->
<script type="text/javascript" src="<!-- TMPL_VAR NAME="yuipath" -->/button/button-min.js"></script> 
<script type="text/javascript" src="<!-- TMPL_VAR NAME="yuipath" -->/container/container_core-min.js"></script> 
<script type="text/javascript" src="<!-- TMPL_VAR NAME="yuipath" -->/menu/menu-min.js"></script> 
<!-- koha core js -->
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/js/staff-global.js"></script>

<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/css/help.css" />
</head>
<body id="help">
