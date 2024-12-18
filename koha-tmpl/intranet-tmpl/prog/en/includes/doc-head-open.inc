<!DOCTYPE html>
<!-- TEMPLATE FILE: [% template.name.split('/').last | html %] -->

[% USE Koha %]
[% USE raw %]
[% USE Dumper( Indent=1, SortKeys=1 ) %]

[% IF Koha.Preference('DumpSearchQueryTemplate') %]
    <!-- SearchQuery
        [% Dumper.dump( search_query ) | $raw %]
    -->
[% END %]

[% IF Koha.Preference('DumpTemplateVarsIntranet') %]
    <!-- prettier-ignore-start -->
    [% TRY %]
        [% USE Stash %]
        <!--
        [% FILTER replace('<!--', '<!- -') %]
            [% FILTER replace('-->', '- ->') %]
                [% Dumper.dump( Stash.stash() ) | $raw %]
            [% END %]
        [% END %]
        -->
    [% CATCH %]
        <!--
            DumpTemplateVarsIntranet is set to 'Do', but
            Template::Plugin::Stash is not installed.
        -->
    [% END %]
    <!-- prettier-ignore-end -->
[% END %]

[% IF ( bidi ) %]<html lang="[% lang | html %]" dir="[% bidi | html %]">[% ELSE %]<html lang="[% lang | html %]">[% END %]
<head>
