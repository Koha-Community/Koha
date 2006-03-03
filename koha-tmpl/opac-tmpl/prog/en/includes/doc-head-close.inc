</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta http-equiv="Content-Language" content="en-us" />
	<!-- TMPL_IF name="opacstylesheet" -->
<style type="text/css"> 
	@import url(<!-- TMPL_VAR NAME="opacstylesheet" -->);
</style>
	<!-- TMPL_ELSE -->
<link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/includes/<!-- TMPL_VAR NAME="opaccolorstylesheet" -->" />
<style type="text/css"> 
	@import url(<!-- TMPL_VAR NAME="themelang" -->/includes/<!-- TMPL_VAR NAME="opaclayoutstylesheet" -->);
</style>
	<!-- /TMPL_IF -->
<script type="text/javascript" language="javascript" src="<TMPL_VAR NAME="themelang">/includes/main.js"></script>
<!-- TMPL_IF NAME="AmazonContent" -->
<script type="text/javascript" language="javascript" src="<TMPL_VAR NAME="themelang">/includes/amazonimages.js"></script>
<!-- /TMPL_IF -->
<script type="text/javascript" language="javascript" src="<TMPL_VAR NAME="themelang">/includes/script.js"></script>
<script type="text/javascript" language="javascript" src="<TMPL_VAR NAME="themelang">/includes/basket.js"></script>
<script type="text/javascript" language="javascript">
	var MSG_BASKET_EMPTY = "You book bag is currently empty";
	var MSG_RECORD_IN_BASKET = "This item is already in your book bag";
	var MSG_RECORD_ADDED = "This item has been added to your book bag";
	var MSG_NRECORDS_ADDED = " item(s) added to your book bag";
	var MSG_NRECORDS_IN_BASKET = "already in the bag";
	var MSG_NO_RECORD_SELECTED = "No item was selected";
	var MSG_NO_RECORD_ADDED = "No item was added to your book bag";
</script>
</head>
<body>
