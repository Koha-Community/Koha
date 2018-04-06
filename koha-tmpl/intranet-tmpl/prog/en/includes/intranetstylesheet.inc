[% USE Asset %]
[% SET intranetstylesheet='staff-global.css' UNLESS intranetstylesheet %]
[% IF (intranetstylesheet.match('^https?:|^\/')) %]
    <link rel="stylesheet" type="text/css" href="[% intranetstylesheet %]" />
[% ELSE %]
    [% Asset.css("css/" _ intranetstylesheet) %]
[% END %]

<!-- local colors -->
[% IF ( intranetcolorstylesheet ) %]
    [% IF (intranetcolorstylesheet.match('^https?:|^\/')) %]
        <link rel="stylesheet" type="text/css" href="[% intranetcolorstylesheet %]" />
    [% ELSE %]
        <link rel="stylesheet" type="text/css" href="[% interface %]/[% theme %]/css/[% intranetcolorstylesheet %]" />
    [% END %]
[% END %]
