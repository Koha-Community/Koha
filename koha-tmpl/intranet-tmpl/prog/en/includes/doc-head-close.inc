[% USE raw %]
[% USE Asset %]
[% USE Koha %]
[% USE KohaPlugins %]
[% USE String %]
[% PROCESS 'html_helpers.inc' %]
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
[% IF logged_in_user %]<meta name="generator" content="Koha [% Koha.Version.maintenance | html %]" />[% END %]
[%# Prevent XFS attacks -%]
[% UNLESS popup %]
    <style id="antiClickjack">body{display:none !important;}</style>
[% END %]

<link rel="shortcut icon" href="[% IF ( IntranetFavicon ) %][% IntranetFavicon | html %][% ELSE %][% interface | html %]/[% theme | html %]/img/favicon.ico[% END %]" type="image/x-icon" />

[% IF ( bidi ) %]
    [% Asset.css("lib/jquery/jquery-ui-rtl-1.13.1.min.css") | $raw %]
[% ELSE %]
    [% Asset.css("lib/jquery/jquery-ui-1.13.1.min.css") | $raw %]
[% END %]
[% Asset.css("lib/bootstrap/bootstrap.min.css") | $raw %]
[% Asset.css("lib/bootstrap/bootstrap-theme.min.css") | $raw %]
[% Asset.css("lib/fontawesome/css/fontawesome.min.css") | $raw %]
[% Asset.css("lib/fontawesome/css/brands.min.css") | $raw %]
[% Asset.css("lib/fontawesome/css/solid.min.css") | $raw %]
[% Asset.css("lib/datatables/datatables.min.css") | $raw %]
[% Asset.css("css/print.css", { media = "print" }) | $raw %]
[% INCLUDE intranetstylesheet.inc %]
[% IF ( bidi ) %][% Asset.css("css/right-to-left.css") | $raw %][% END %]

<script>
var Koha = {};
[% IF CAN_user_parameters_manage_column_config %]
    var CAN_user_parameters_manage_column_config = 1;
[% ELSE %]
    var CAN_user_parameters_manage_column_config = 0;
[% END %]
</script>

[% IF lang && lang != 'en' %]
    [% Asset.js(lang _ '/js/locale_data.js') | $raw %]
[% END %]
[% Asset.js('js/Gettext.js') | $raw %]
[% Asset.js('js/i18n.js') | $raw %]

[% IF ( login ) %]
    [% Asset.css("css/login.css") | $raw %]
[% END %]
[% IF ( IntranetUserCSS ) %]<style>[% IntranetUserCSS | $raw %]</style>[% END %]

[% KohaPlugins.get_plugins_intranet_head | $raw %]

[% UNLESS ( footerjs ) %]
    [% INCLUDE js_includes.inc %]
[% END %]
