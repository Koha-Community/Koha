[% SET intranetstylesheet='staff-global_' _ KOHA_VERSION _ '.css' UNLESS intranetstylesheet %]
[% IF (intranetstylesheet.match('^https?:|^\/')) %]
    <link rel="stylesheet" type="text/css" href="[% intranetstylesheet %]" />
[% ELSE %]
    <link rel="stylesheet" type="text/css" href="[% interface %]/[% theme %]/css/[% intranetstylesheet %]" />
[% END %]

<!-- local colors -->
[% IF ( intranetcolorstylesheet ) %]
    [% IF (intranetcolorstylesheet.match('^https?:|^\/')) %]
        <link rel="stylesheet" type="text/css" href="[% intranetcolorstylesheet %]" />
    [% ELSE %]
        <link rel="stylesheet" type="text/css" href="[% interface %]/[% theme %]/css/[% intranetcolorstylesheet %]" />
    [% END %]
[% END %]
