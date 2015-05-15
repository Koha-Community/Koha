<!DOCTYPE html>
<!-- TEMPLATE FILE: [% template.name.split('/').last %] -->

[% USE Koha %]
[% IF Koha.Preference('DumpTemplateVarsOpac') %]
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
            DumpTemplateVarsOpac is set to 'Do', but
            Template::Plugin::Stash is not installed.
        -->
    [% END %]
[% END %]

[% IF ( bidi ) %]<html lang="[% lang %]" dir="[% bidi %]" class="no-js">[% ELSE %]<html lang="[% lang %]" class="no-js">[% END %]
<head>
