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

<link rel="stylesheet" type="text/css" href="[% interface %]/lib/jquery/jquery-ui-1.11.4.min.css" />
<link rel="stylesheet" type="text/css" href="[% interface %]/lib/bootstrap/bootstrap.min.css" />
<link rel="stylesheet" type="text/css" href="[% interface %]/lib/bootstrap/bootstrap-theme.min.css" />
<link rel="stylesheet" type="text/css" href="[% interface %]/lib/font-awesome/css/font-awesome.min.css" />
<link rel="stylesheet" type="text/css" media="print" href="[% interface %]/[% theme %]/css/print.css" />
[% INCLUDE intranetstylesheet.inc %]
[% IF ( bidi ) %]<link rel="stylesheet" type="text/css" href="[% interface %]/[% theme %]/css/right-to-left.css" />[% END %]

[% IF ( login ) %]
    <link rel="stylesheet" type="text/css" href="[% interface %]/[% theme %]/css/login.css" />
[% END %]
[% IF ( IntranetUserCSS ) %]<style type="text/css">[% IntranetUserCSS %]</style>[% END %]

[% UNLESS ( footerjs ) %]
    [% INCLUDE js_includes.inc %]
[% END %]
