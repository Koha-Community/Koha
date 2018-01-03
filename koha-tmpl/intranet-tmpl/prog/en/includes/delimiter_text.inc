[% SWITCH Koha.Preference('delimiter') %]
    [% CASE '#' %]Pound (#) separated text (.csv)
    [% CASE ',' %]Comma separated text (.csv)
    [% CASE '/' %]Slash separated text (.csv)
    [% CASE ';' %]Semicolon separated text (.csv)
    [% CASE '\\' %]Backslash separated text (.csv)
    [% CASE 'tabulation' %]Tab separated text (.csv)
[% END %]
