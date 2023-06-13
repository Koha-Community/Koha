[% USE raw %]
[% USE Asset %]
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link rel="shortcut icon" href="[% IF ( IntranetFavicon ) %][% IntranetFavicon | html %][% ELSE %][% interface | html %]/[% theme | html %]/img/favicon.ico[% END %]" type="image/x-icon" />
[% Asset.css("lib/bootstrap/bootstrap.min.css") | $raw %]
[% Asset.css("lib/fontawesome/css/fontawesome.min.css") | $raw %]
[% Asset.css("lib/fontawesome/css/brands.min.css") | $raw %]
[% Asset.css("lib/fontawesome/css/solid.min.css") | $raw %]
[% Asset.css("css/installer.css")  | $raw %]
<script>
var Koha = {};
</script>
[% IF lang && lang != 'en' %]
    [% Asset.js(lang _ '/js/locale_data.js') | $raw %]
[% END %]
[% Asset.js('js/Gettext.js') | $raw %]
[% Asset.js('js/i18n.js') | $raw %]
<style id="antiClickjack">body{display:none !important;}</style>
