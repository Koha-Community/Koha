[% USE raw %]
[% USE Asset %]
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="shortcut icon" href="[% IF ( IntranetFavicon ) %][% IntranetFavicon | html %][% ELSE %][% interface | html %]/[% theme | html %]/img/favicon.ico[% END %]" type="image/x-icon" />
[% Asset.css("lib/jquery/jquery-ui-1.11.4.min.css") | $raw %]
[% Asset.css("lib/bootstrap/bootstrap.min.css") | $raw %]
[% Asset.css("css/installer.css")  | $raw %]
<style id="antiClickjack">body{display:none !important;}</style>
