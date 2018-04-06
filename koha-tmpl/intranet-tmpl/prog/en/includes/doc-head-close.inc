[% USE Asset %]
[% USE Koha %]
[% USE String %]
[% PROCESS 'html_helpers.inc' %]
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
[%# Prevent XFS attacks -%]
[% UNLESS popup %]
    <style id="antiClickjack">body{display:none !important;}</style>
[% END %]

<link rel="shortcut icon" href="[% IF ( IntranetFavicon ) %][% IntranetFavicon %][% ELSE %][% interface %]/[% theme %]/img/favicon.ico[% END %]" type="image/x-icon" />

[% Asset.css("lib/jquery/jquery-ui-1.11.4.min.css") %]
[% Asset.css("lib/bootstrap/bootstrap.min.css") %]
[% Asset.css("lib/bootstrap/bootstrap-theme.min.css") %]
[% Asset.css("lib/font-awesome/css/font-awesome.min.css") %]
[% Asset.css("css/print.css", { media = "print" }) %]
[% INCLUDE intranetstylesheet.inc %]
[% IF ( bidi ) %][% Asset.css("css/right-to-left.css") %][% END %]

[% IF ( login ) %]
    [% Asset.css("css/login.css") %]
[% END %]
[% IF ( IntranetUserCSS ) %]<style type="text/css">[% IntranetUserCSS %]</style>[% END %]

[% UNLESS ( footerjs ) %]
    [% INCLUDE js_includes.inc %]
[% END %]
