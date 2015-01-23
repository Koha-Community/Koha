[% USE raw %]
[% USE Asset %]
[% INCLUDE 'doc-head-open.inc' %]
<title>Online help</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="shortcut icon" href="[% IF ( IntranetFavicon ) %][% IntranetFavicon | html %][% ELSE %][% interface | html %]/[% theme | html %]/img/favicon.ico[% END %]" type="image/x-icon" />
[% Asset.css("lib/jquery/jquery-ui-1.11.4.min.css") | $raw %]
[% Asset.css("css/print.css", { media = "print" }) | $raw %]
[% INCLUDE intranetstylesheet.inc %]
[% IF ( bidi ) %]
   [% Asset.css("css/right-to-left.css") | $raw %]
[% END %]
[% Asset.js("lib/jquery/jquery-2.2.3.min.js") | $raw %]
[% Asset.js("lib/jquery/jquery-migrate-1.3.0.min.js") | $raw %]
[% Asset.js("lib/jquery/jquery-ui-1.11.4.min.js") | $raw %]
[% Asset.js("lib/shortcut/shortcut.js") | $raw %]
<!-- koha core js -->
[% Asset.js("js/staff-global.js") | $raw %]

[% Asset.css("css/help.css") | $raw %]
</head>
<body id="help" class="help">
