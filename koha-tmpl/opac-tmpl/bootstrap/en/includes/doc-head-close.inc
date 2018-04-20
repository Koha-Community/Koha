[% USE raw %]
[%- USE KohaPlugins -%]
[% USE Asset %]
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="generator" content="Koha [% Version | html %]" /> <!-- leave this for stats -->
<meta name="viewport" content="width=device-width, initial-scale=1" />
<link rel="shortcut icon" href="[% IF ( OpacFavicon ) %][% OpacFavicon | html %][% ELSE %][% interface | html %]/[% theme | html %]/images/favicon.ico[% END %]" type="image/x-icon" />
[% IF ( bidi ) %]
    [% Asset.css("lib/bootstrap/css/bootstrap-rtl.min.css") | $raw %]
[% ELSE %]
    [% Asset.css("lib/bootstrap/css/bootstrap.min.css") | $raw %]
[% END %]

[% IF ( bidi ) %]
    [% Asset.css("lib/jquery/jquery-ui-rtl.css") | $raw %]
[% ELSE %]
    [% Asset.css("lib/jquery/jquery-ui.css") | $raw %]
[% END %]

[% SET opaclayoutstylesheet='opac_' _ KOHA_VERSION _ '.css' UNLESS opaclayoutstylesheet %]
[% IF (opaclayoutstylesheet.match('^https?:|^\/')) %]
    <link rel="stylesheet" type="text/css" href="[% opaclayoutstylesheet | html %]" />
[% ELSE %]
    [% Asset.css("css/" _ opaclayoutstylesheet) | $raw %]
[% END %]
[% IF ( OpacAdditionalStylesheet ) %]
    [% IF (OpacAdditionalStylesheet.match('^https?:|^\/')) %]
        <link rel="stylesheet" type="text/css" href="[% OpacAdditionalStylesheet | html %]" />
    [% ELSE %]
        <link rel="stylesheet" type="text/css" href="[% interface | html %]/[% theme | html %]/css/[% OpacAdditionalStylesheet | html %]" />
    [% END %]
[% END %]
[% IF ( opac_css_override ) %]
    <link rel="stylesheet" type="text/css" href="[% interface | html %]/[% theme | html %]/css/[% opac_css_override | html %]" />
[% END %]
[% Asset.css("css/print.css", { media = "print" }) | $raw %]
[% IF ( bidi ) %]
    [% Asset.css("css/right-to-left.css") | $raw %]
[% END %]
[% IF ( OPACUserCSS ) %]<style>[% OPACUserCSS | $raw %]</style>[% END %]
[% IF SCO_login %]
    [% SET SCOUserCSS = Koha.Preference('SCOUserCSS') %]
    [% IF SCOUserCSS %]
        <style>[% SCOUserCSS | $raw %]</style>
    [% END %]
[% END %]
<link rel="unapi-server" type="application/xml" title="unAPI" href="[% OPACBaseURL | html %]/cgi-bin/koha/unapi" />
[% PROCESS cssinclude %]
<!-- Respond.js brings responsive layout behavior to IE < v.9 -->
<!--[if lt IE 9]>
    <script src="[% interface | html %]/[% theme | html %]/lib/respond.min.js"></script>
<![endif]-->
<script>
    function _(s) { return s } // dummy function for gettext
</script>
[% Asset.js("lib/modernizr.min.js") | $raw %]
[% Asset.css("lib/font-awesome/css/font-awesome.min.css") | $raw %]
[% PROCESS 'html_helpers.inc' %]
[% KohaPlugins.get_plugins_opac_head | $raw %]
