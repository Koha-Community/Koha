[% INCLUDE 'doc-head-open.inc' %]
<title>Online help</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="shortcut icon" href="[% IF ( IntranetFavicon ) %][% IntranetFavicon %][% ELSE %][% interface %]/[% theme %]/img/favicon.ico[% END %]" type="image/x-icon" />
<link rel="stylesheet" type="text/css" href="[% interface %]/lib/jquery/jquery-ui-1.11.4.min_[% KOHA_VERSION %].css" />
<link rel="stylesheet" type="text/css" media="print" href="[% interface %]/[% theme %]/css/print_[% KOHA_VERSION %].css" />
[% INCLUDE intranetstylesheet.inc %]
[% IF ( bidi ) %]
   <link rel="stylesheet" type="text/css" href="[% interface %]/[% theme %]/css/right-to-left_[% KOHA_VERSION %].css" />
[% END %]
<script type="text/javascript" src="[% interface %]/lib/jquery/jquery-2.2.3.min_[% KOHA_VERSION %].js"></script>
<script type="text/javascript" src="[% interface %]/lib/jquery/jquery-migrate-1.3.0.min_[% KOHA_VERSION %].js"></script>
<script type="text/javascript" src="[% interface %]/lib/jquery/jquery-ui-1.11.4.min_[% KOHA_VERSION %].js"></script>
<script type="text/javascript" src="[% interface %]/lib/shortcut/shortcut_[% KOHA_VERSION %].js"></script>
<!-- koha core js -->
<script type="text/javascript" src="[% interface %]/[% theme %]/js/staff-global_[% KOHA_VERSION %].js"></script>

<link rel="stylesheet" type="text/css" href="[% interface %]/[% theme %]/css/help_[% KOHA_VERSION %].css" />
</head>
<body id="help" class="help">
