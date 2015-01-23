<!DOCTYPE html>
<!-- TEMPLATE FILE: [% template.name.split('/').last | html %] -->

[% USE Koha %]
[% IF Koha.Preference('DumpTemplateVarsIntranet') %]
    [% TRY %]
        [% USE Stash %]
        [% USE Dumper %]
        <!--
        [% FILTER replace('<!--', '<!- -') %]
            [% FILTER replace('-->', '- ->') %]
                [% Dumper.dump( Stash.stash() ) | html %]
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

[% IF ( bidi ) %]<html lang="[% lang | html %]" dir="[% bidi | html %]">[% ELSE %]<html lang="[% lang | html %]">[% END %]
<head>
