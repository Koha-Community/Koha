[% SWITCH Koha.Preference('delimiter') %]
    [% CASE '#' %]<span>Pound (#) separated text (.csv)</span>
    [% CASE ',' %]<span>Comma separated text (.csv)</span>
    [% CASE '/' %]<span>Slash separated text (.csv)</span>
    [% CASE ';' %]<span>Semicolon separated text (.csv)</span>
    [% CASE '\\' %]<span>Backslash separated text (.csv)</span>
    [% CASE 'tabulation' %]<span>Tab separated text (.csv)</span>
[% END %]
