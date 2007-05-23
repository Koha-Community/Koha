</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<!-- TMPL_IF name="RSS" -->
    <link rel="alternate" type="application/rss+xml" title="Koha - RSS" href="<!-- TMPL_VAR name="site_url"-->/opac-rss.pl?q=<!-- TMPL_VAR name="searchdesc"-->">
<!-- /TMPL_IF -->
<!-- TMPL_IF name="opacstylesheet" -->
        <style type="text/css"> 
            @import url(<!-- TMPL_VAR NAME="opacstylesheet" -->);
        </style>
<!-- TMPL_ELSE -->
    <!-- TMPL_IF name="opaccolorstylesheet" -->
        <link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/includes/<!-- TMPL_VAR NAME="opaccolorstylesheet" -->" />
    <!-- TMPL_ELSE -->
        <link rel="stylesheet" type="text/css" href="<!-- TMPL_VAR NAME="themelang" -->/includes/opac.css" />
    <!-- /TMPL_IF -->
    <style type="text/css">
        @import url(<!-- TMPL_VAR NAME="themelang" -->/includes/<!-- TMPL_VAR NAME="opaclayoutstylesheet" -->);
    </style>
<!-- /TMPL_IF -->

<script type="text/javascript" language="javascript" src="../..<!-- TMPL_VAR NAME="themelang" -->/includes/main.js" ></script>

<!-- TMPL_IF NAME="AmazonContent" -->
<script type="text/javascript" language="javascript" src="../..<!-- TMPL_VAR NAME="themelang" -->/includes/amazonimages.js" ></script>
<!-- /TMPL_IF -->

<script type="text/javascript" language="javascript" src="../..<!-- TMPL_VAR NAME="themelang" -->/includes/script.js" ></script>

<script type="text/javascript" language="javascript" src="../..<!-- TMPL_VAR NAME="themelang" -->/includes/basket.js" ></script>

<script type="text/javascript" language="javascript">
    function _(s) { return s } // dummy function for gettext
    var MSG_BASKET_EMPTY = _("Votre panier est actuellement vide");
    var MSG_RECORD_IN_BASKET = _("Ce document est déjà dans votre panier");
    var MSG_RECORD_ADDED = _("Ce document a été ajouté à votre panier");
    var MSG_NRECORDS_ADDED = _("Document(s) ajouté(s) à votre panier");
    var MSG_NRECORDS_IN_BASKET = _("Déjà dans le panier");
    var MSG_NO_RECORD_SELECTED = _("Aucun document sélectionné");
    var MSG_NO_RECORD_ADDED = _("Aucun document ajouté dans votre panier");
</script>

</head>
<body>
