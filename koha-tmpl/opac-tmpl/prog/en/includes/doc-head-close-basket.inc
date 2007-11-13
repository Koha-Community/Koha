</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Content-Language" content="en-us" />
<link rel="shortcut icon" href="<!-- TMPL_VAR NAME="themelang" -->/includes/favicon.ico" type="image/x-icon" />
<!-- TMPL_IF name="opacstylesheet" --><style type="text/css"> 
            @import url(<!-- TMPL_VAR NAME="opacstylesheet" -->);
        </style>
<!-- TMPL_ELSE -->
<!-- TMPL_IF name="opaccolorstylesheet" -->
        <link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/css<!-- TMPL_VAR NAME="opaccolorstylesheet" -->" />
    <!-- TMPL_ELSE -->
        <link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/css/opac.css" />
    <!-- /TMPL_IF -->
    <style type="text/css">
        @import url(<!-- TMPL_VAR NAME="themelang" -->/css/<!-- TMPL_VAR NAME="opaclayoutstylesheet" -->);
    </style>
<!-- /TMPL_IF -->
<script type="text/javascript" language="javascript" src="<!-- TMPL_VAR NAME="themelang" -->/js/script.js" ></script>
<script type="text/javascript" language="javascript" src="<!-- TMPL_VAR NAME="themelang" -->/js/basket.js" ></script>
<script type="text/javascript" language="javascript">
    var MSG_NO_RECORD_SELECTED = "No biblio selected";
    var MSG_NO_RECORD_ADDED = "No biblio added";
    var MSG_CONFIRM_DEL_BASKET = "Are you sure you want to empty your book bag?"
    var MSG_CONFIRM_DEL_RECORDS = "Are you sure you want to remove the selected items?";
</script>
</head>
<body>
