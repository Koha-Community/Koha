[% SET intranetstylesheet='staff-global.css' UNLESS intranetstylesheet %]
[% IF (intranetstylesheet.match('^https?:|^\/')) %]
    <link rel="stylesheet" type="text/css" href="[% intranetstylesheet %]" />
[% ELSE %]
    <link rel="stylesheet" type="text/css" href="[% themelang %]/css/[% intranetstylesheet %]" />
[% END %]

<!-- local colors -->
[% IF ( intranetcolorstylesheet ) %]
    [% IF (intranetcolorstylesheet.match('^https?:|^\/')) %]
        <link rel="stylesheet" type="text/css" href="[% intranetcolorstylesheet %]" />
    [% ELSE %]
        <link rel="stylesheet" type="text/css" href="[% themelang %]/css/[% intranetcolorstylesheet %]" />
    [% END %]
[% END %]
