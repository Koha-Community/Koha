[% INCLUDE 'doc-head-open.inc' %]
<title>Online Help</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="shortcut icon" href="[% IF ( IntranetFavicon ) %][% IntranetFavicon %][% ELSE %][% themelang %]/includes/favicon.ico[% END %]" type="image/x-icon" />
<link rel="stylesheet" type="text/css" media="print" href="[% themelang %]/css/print.css" />
[% IF ( intranetstylesheet ) %]
<link rel="stylesheet" type="text/css" href="[% intranetstylesheet %]" />
[% ELSE %]
<link rel="stylesheet" type="text/css" href="[% themelang %]/css/staff-global.css" />
[% END %]
<script type="text/javascript" src="[% themelang %]/lib/jquery/jquery.js"></script>
<script type="text/javascript" src="[% themelang %]/lib/jquery/plugins/ui.tabs.js"></script>
<script type="text/javascript" src="[% themelang %]/lib/jquery/plugins/jquery.hotkeys.min.js"></script>
<!-- local colors -->
[% IF ( intranetcolorstylesheet ) %]
<link rel="stylesheet" type="text/css" href="[% themelang %]/css/[% intranetcolorstylesheet %]" />
[% END %]
<!-- yui js --> 
<script type="text/javascript" src="[% yuipath %]/utilities/utilities.js"></script> 
[% IF ( CircAutocompl ) %]<script type="text/javascript" src="[% yuipath %]/autocomplete/autocomplete-min.js"></script> [% END %]
<script type="text/javascript" src="[% yuipath %]/button/button-min.js"></script> 
<script type="text/javascript" src="[% yuipath %]/container/container_core-min.js"></script> 
<script type="text/javascript" src="[% yuipath %]/menu/menu-min.js"></script> 
<!-- koha core js -->
<script type="text/javascript" src="[% themelang %]/js/staff-global.js"></script>

<link rel="stylesheet" type="text/css" href="[% themelang %]/css/help.css" />
</head>
<body id="help">
