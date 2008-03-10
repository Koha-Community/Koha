<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="shortcut icon" href="<!-- TMPL_VAR NAME="themelang" -->/includes/favicon.ico" type="image/x-icon" />
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/lib/jquery/plugins/jquery.tabs.css" />
<link rel="stylesheet" type="text/css" media="print" href="<!-- TMPL_VAR name="themelang" -->/css/print.css" />
<!-- TMPL_IF name="intranetstylesheet" -->
    <link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="intranetstylesheet" -->" />
<!-- TMPL_ELSE -->
    <link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/css/staff-global.css" />
<!-- /TMPL_IF -->
        <!-- Additional IE/Win specific style sheet (Conditional Comments) -->
        <!--[if lte IE 7]>
        <link rel="stylesheet" href="<!-- TMPL_VAR NAME="themelang" -->/lib/jquery/plugins/jquery.tabs-ie.css" type="text/css" media="projection, screen">
        <![endif]-->
<!-- TMPL_IF NAME="css_libs" --><!-- TMPL_LOOP NAME="css_libs" --><link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/<!-- TMPL_VAR NAME="lib" -->" /><!-- /TMPL_LOOP --><!-- /TMPL_IF -->

<!-- TMPL_IF NAME="css_module" --><link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/css/modules/<!-- TMPL_VAR NAME="css_module" -->" /><!-- /TMPL_IF -->
<!-- TMPL_IF NAME="css_page" --><link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/css/pages/<!-- TMPL_VAR NAME="css_page" -->" /><!-- /TMPL_IF -->

<!-- TMPL_IF NAME="css_widgets" -->
<!-- TMPL_LOOP NAME="css_widgets" -->
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/<!-- TMPL_VAR NAME="widget" -->" />
<!-- /TMPL_LOOP -->
<!-- /TMPL_IF -->
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/lib/jquery/jquery.js"></script>
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/lib/jquery/plugins/jquery.tabs.pack.js"></script><script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/lib/jquery/plugins/jquery.hotkeys.js"></script>
<!-- TMPL_IF NAME="js_libs" -->
<!-- TMPL_LOOP NAME="js_libs" --><script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/<!-- TMPL_VAR NAME="lib" -->"></script>
<!-- /TMPL_LOOP -->
<!-- /TMPL_IF -->
<!-- TMPL_IF NAME="js_module" -->
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/js/modules/<!-- TMPL_VAR NAME="js_module" -->"></script>
<!-- /TMPL_IF -->
<!-- TMPL_IF NAME="js_page" -->
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/js/pages/<!-- TMPL_VAR NAME="js_page" -->"></script>
<!-- /TMPL_IF -->

<!-- TMPL_IF NAME="js_widgets" -->
<!-- TMPL_LOOP NAME="js_widgets" -->
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/<!-- TMPL_VAR NAME="widget" -->"></script>
<!-- /TMPL_LOOP -->
<!-- /TMPL_IF -->
<!-- TMPL_IF NAME="popup" --><link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/css/intranet2popup.css" /><!-- /TMPL_IF -->
<!-- TMPL_IF NAME="login" --><link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/css/login.css" /><!-- /TMPL_IF -->
<!-- TMPL_IF NAME="wizard" --><link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/css/wizard.css" />
<!-- /TMPL_IF -->

<!-- local colors -->
<!-- TMPL_IF name="intranetcolorstylesheet" -->
    <link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/css/<!-- TMPL_VAR NAME="intranetcolorstylesheet" -->" />
<!-- /TMPL_IF -->
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/lib/yui/button.css" />
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/lib/yui/menu.css" />
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/lib/yui/container.css" />
<script type="text/javascript" src="<!-- TMPL_VAR NAME="yuipath" -->/yahoo-dom-event/yahoo-dom-event.js"></script>
<script type="text/javascript" src="<!-- TMPL_VAR NAME="yuipath" -->/element/element-beta-min.js"></script>
<script type="text/javascript" src="<!-- TMPL_VAR NAME="yuipath" -->/container/container_core-min.js"></script>
<script type="text/javascript" src="<!-- TMPL_VAR NAME="yuipath" -->/menu/menu-min.js"></script>
<script type="text/javascript" src="<!-- TMPL_VAR NAME="yuipath" -->/button/button-beta-min.js"></script>
<script type="text/javascript" src="<!-- TMPL_VAR NAME="yuipath" -->/utilities/utilities.js"></script>
<!-- TMPL_IF NAME="CircAutocompl" -->
<script type="text/javascript" src="<!-- TMPL_VAR NAME="yuipath" -->/autocomplete/autocomplete-min.js"></script>
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/lib/yui/autocomplete.css" />
<!-- /TMPL_IF -->
<script type="text/javascript" src="<!-- TMPL_VAR name="themelang" -->/js/staff-global.js"></script>
