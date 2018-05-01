[%- USE KohaPlugins -%]
[% USE Asset %]
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="generator" content="Koha [% Version %]" /> <!-- leave this for stats -->
<meta name="viewport" content="width=device-width, initial-scale=1" />
<link rel="shortcut icon" href="[% IF ( OpacFavicon ) %][% OpacFavicon %][% ELSE %][% interface %]/[% theme %]/images/favicon.ico[% END %]" type="image/x-icon" />
[% IF ( bidi ) %]
    [% Asset.css("lib/bootstrap/css/bootstrap-rtl.min.css") %]
[% ELSE %]
    [% Asset.css("lib/bootstrap/css/bootstrap.min.css") %]
[% END %]

[% IF ( bidi ) %]
    [% Asset.css("lib/jquery/jquery-ui-rtl.css") %]
[% ELSE %]
    [% Asset.css("lib/jquery/jquery-ui.css") %]
[% END %]

[% SET opaclayoutstylesheet='opac.css' UNLESS opaclayoutstylesheet %]
[% IF (opaclayoutstylesheet.match('^https?:|^\/')) %]
    <link rel="stylesheet" type="text/css" href="[% opaclayoutstylesheet %]" />
[% ELSE %]
    [% Asset.css("css/" _ opaclayoutstylesheet) %]
[% END %]
[% IF ( OpacAdditionalStylesheet ) %]
    [% IF (OpacAdditionalStylesheet.match('^https?:|^\/')) %]
        <link rel="stylesheet" type="text/css" href="[% OpacAdditionalStylesheet %]" />
    [% ELSE %]
        <link rel="stylesheet" type="text/css" href="[% interface %]/[% theme %]/css/[% OpacAdditionalStylesheet %]" />
    [% END %]
[% END %]
[% IF ( opac_css_override ) %]
    <link rel="stylesheet" type="text/css" href="[% interface %]/[% theme %]/css/[% opac_css_override %]" />
[% END %]
[% Asset.css("css/print.css", { media = "print" }) %]
[% IF ( bidi ) %]
    [% Asset.css("css/right-to-left.css") %]
[% END %]
[% IF ( OPACUserCSS ) %]<style>[% OPACUserCSS %]</style>[% END %]
[% IF SCO_login %]
    [% SET SCOUserCSS = Koha.Preference('SCOUserCSS') %]
    [% IF SCOUserCSS %]
        <style>[% SCOUserCSS %]</style>
    [% END %]
[% END %]
<link rel="unapi-server" type="application/xml" title="unAPI" href="[% OPACBaseURL %]/cgi-bin/koha/unapi" />
[% PROCESS cssinclude %]
<!-- Respond.js brings responsive layout behavior to IE < v.9 -->
<!--[if lt IE 9]>
    <script src="[% interface %]/[% theme %]/lib/respond.min.js"></script>
<![endif]-->
<script>
    function _(s) { return s } // dummy function for gettext
</script>
[% Asset.js("lib/modernizr.min.js") %]
[% Asset.css("lib/font-awesome/css/font-awesome.min.css") %]
[% PROCESS 'html_helpers.inc' %]
[% KohaPlugins.get_plugins_opac_head %]
