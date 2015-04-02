<!DOCTYPE html>
<!-- TEMPLATE FILE: [% template.name.split('/').last %] -->

[% USE Koha %]
[% IF Koha.Preference('DumpTemplateVarsIntranet') %]
    [% USE Stash %]
    [% USE Dumper %]
    <!--
    [% FILTER replace('<!--', '<!- -') %]
        [% FILTER replace('-->', '- ->') %]
            [% Dumper.dump( Stash.stash() ) %]
        [% END %]
    [% END %]
    -->
[% END %]

[% IF ( bidi ) %]<html lang="[% lang %]" dir="[% bidi %]">[% ELSE %]<html lang="[% lang %]">[% END %]
<head>
