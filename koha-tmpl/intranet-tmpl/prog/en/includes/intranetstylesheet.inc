[% USE raw %]
[% USE Asset %]
[% IF ( bidi ) %]
    [% SET intranetstylesheet='staff-global-rtl.css' UNLESS intranetstylesheet %]
[% ELSE %]
    [% SET intranetstylesheet='staff-global.css' UNLESS intranetstylesheet %]
[% END %]
[% IF (intranetstylesheet.match('^https?:|^\/')) %]
    <link rel="stylesheet" type="text/css" href="[% intranetstylesheet | html %]" />
[% ELSE %]
    [% Asset.css("css/" _ intranetstylesheet) | $raw %]
[% END %]

<!-- local colors -->
[% IF ( intranetcolorstylesheet ) %]
    [% IF (intranetcolorstylesheet.match('^https?:|^\/')) %]
        <link rel="stylesheet" type="text/css" href="[% intranetcolorstylesheet | html %]" />
    [% ELSE %]
        <link rel="stylesheet" type="text/css" href="[% interface | html %]/[% theme | html %]/css/[% intranetcolorstylesheet | html %]" />
    [% END %]
[% END %]
