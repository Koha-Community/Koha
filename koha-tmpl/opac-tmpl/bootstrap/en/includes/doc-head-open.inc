<!DOCTYPE html>
<!-- TEMPLATE FILE: [% template.name.split('/').last %] -->

[% USE Koha %]
[% IF Koha.Preference('DumpTemplateVarsOpac') %]
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

[% IF ( bidi ) %]<html lang="[% lang %]" dir="[% bidi %]" class="no-js">[% ELSE %]<html lang="[% lang %]" class="no-js">[% END %]
<head>
