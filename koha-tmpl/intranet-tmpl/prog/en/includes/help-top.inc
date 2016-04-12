[% INCLUDE 'doc-head-open.inc' %]
<title>Online help</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="shortcut icon" href="[% IF ( IntranetFavicon ) %][% IntranetFavicon %][% ELSE %][% interface %]/[% theme %]/img/favicon.ico[% END %]" type="image/x-icon" />
<link rel="stylesheet" type="text/css" href="[% interface %]/lib/jquery/jquery-ui-1.11.4.min.css" />
<link rel="stylesheet" type="text/css" media="print" href="[% interface %]/[% theme %]/css/print.css" />
[% INCLUDE intranetstylesheet.inc %]
[% IF ( bidi ) %]
   <link rel="stylesheet" type="text/css" href="[% interface %]/[% theme %]/css/right-to-left.css" />
[% END %]
<script type="text/javascript" src="[% interface %]/lib/jquery/jquery-2.2.3.min.js"></script>
<script type="text/javascript" src="[% interface %]/lib/jquery/jquery-migrate-1.3.0.min.js"></script>
<script type="text/javascript" src="[% interface %]/lib/jquery-ui-1.11.4.min.js"></script>
<script type="text/javascript" src="[% interface %]/lib/shortcut/shortcut.js"></script>
<!-- koha core js -->
<script type="text/javascript" src="[% interface %]/[% theme %]/js/staff-global.js"></script>

<link rel="stylesheet" type="text/css" href="[% interface %]/[% theme %]/css/help.css" />
</head>
<body id="help" class="help">
