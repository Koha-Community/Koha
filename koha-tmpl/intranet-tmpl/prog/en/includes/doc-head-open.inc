<!DOCTYPE html>
<!-- TEMPLATE FILE: [% template.name.split('/').last %] -->

[% USE Koha %]
[% IF Koha.Preference('DumpTemplateVarsIntranet') %]
    [% TRY %]
        [% USE Stash %]
        [% USE Dumper %]
        <!--
        [% FILTER replace('<!--', '<!- -') %]
            [% FILTER replace('-->', '- ->') %]
                [% Dumper.dump( Stash.stash() ) %]
            [% END %]
        [% END %]
        -->
    [% CATCH %]
        <!--
            DumpTemplateVarsIntranet is set to 'Do', but
            Template::Plugin::Stash is not installed.
        -->
    [% END %]
[% END %]

[% IF ( bidi ) %]<html lang="[% lang %]" dir="[% bidi %]">[% ELSE %]<html lang="[% lang %]">[% END %]
<head>
