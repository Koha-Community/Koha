<!DOCTYPE html>
<!-- TEMPLATE FILE: [% template.name.split('/').last | html %] -->

[% USE raw %]
[% USE Koha %]
[% USE Dumper( Indent=1, SortKeys=1 ) %]

[% IF Koha.Preference('DumpSearchQueryTemplate') %]
    <!-- SearchQuery
        [% Dumper.dump( search_query ) | $raw %]
    -->
[% END %]

[% IF Koha.Preference('DumpTemplateVarsOpac') %]
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
            DumpTemplateVarsOpac is set to 'Do', but
            Template::Plugin::Stash is not installed.
        -->
    [% END %]
    <!-- prettier-ignore-end -->
[% END %]

[% IF ( bidi ) %]<html lang="[% lang | html %]" dir="[% bidi | html %]" class="no-js">[% ELSE %]<html lang="[% lang | html %]" class="no-js">[% END %]
<head>
