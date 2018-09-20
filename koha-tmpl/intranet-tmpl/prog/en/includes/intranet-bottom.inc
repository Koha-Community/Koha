[% USE raw %]
[% USE Koha %]
        </div>
[% IF ( ( languages_loop ) && ( ! popup_window ) && ( Koha.Preference('StaffLangSelectorMode') == 'both' || Koha.Preference('StaffLangSelectorMode') == 'footer') ) %]
    [% UNLESS ( one_language_enabled ) %]
        <div id="changelanguage" class="navbar navbar-default navbar-fixed-bottom">
            <div class="container-fluid">
        <ul id="i18nMenu" class="nav navbar-nav">
        [% FOREACH languages_loo IN languages_loop %]

            [% IF ( languages_loo.group_enabled ) %]
            [% IF ( languages_loo.plural ) %]
                <li class="dropdown"><a class="dropdown-toggle dropup" data-toggle="dropdown" id="show[% languages_loo.rfc4646_subtag | html %]" href="#">
                    [% IF ( languages_loo.native_description ) %]
                        [% languages_loo.native_description | html %]
                    [% ELSE %]
                        [% languages_loo.rfc4646_subtag | html %]
                    [% END %]
                    [% FOREACH sublanguages_loo IN languages_loo.sublanguages_loop %]
                        [% IF ( sublanguages_loo.enabled ) %]
                            [% IF ( sublanguages_loo.sublanguage_current ) %]
                                <span class="sublanguage-selected">([% sublanguages_loo.rfc4646_subtag | html %])</span>
                            [% END %]
                        [% END %]
                    [% END %]
                <span class="caret"></span></a>
            <ul id="sub[% languages_loo.rfc4646_subtag | html %]" class="dropdown-menu dropdown-menu-right">
            [% FOREACH sublanguages_loo IN languages_loo.sublanguages_loop %]
        [% IF ( sublanguages_loo.enabled ) %]
                [% IF ( sublanguages_loo.sublanguage_current ) %]
                    <li class="navbar-text"> <span class="currentlanguage disabled">[% sublanguages_loo.native_description | html %] [% sublanguages_loo.script_description | html %] [% sublanguages_loo.region_description | html %] [% sublanguages_loo.variant_description | html %] ([% sublanguages_loo.rfc4646_subtag | html %])</span></li>
                [% ELSE %]
                <li><a href="/cgi-bin/koha/changelanguage.pl?language=[% sublanguages_loo.rfc4646_subtag | html %]"> [% sublanguages_loo.native_description | html %] [% sublanguages_loo.script_description | html %] [% sublanguages_loo.region_description | html %] [% sublanguages_loo.variant_description | html %] ([% sublanguages_loo.rfc4646_subtag | html %])</a></li>
        [% END %]
                [% END %]

            [% END %]
            </ul></li>

            [% ELSE %]
            [% IF ( languages_loo.group_enabled ) %]
                [% IF ( languages_loo.current ) %]
                    <li class="navbar-text">
                        [% IF ( languages_loo.native_description ) %]
                            <span class="currentlanguage">[% languages_loo.native_description | html %]</span>
                        [% ELSE %]
                            <span class="currentlanguage">[% languages_loo.rfc4646_subtag | html %]</span>
                        [% END %]
                    </li>
                [% ELSE %]
                    <li><a href="/cgi-bin/koha/changelanguage.pl?language=[% languages_loo.rfc4646_subtag | html %]">
                        [% IF ( languages_loo.native_description ) %]
                            [% languages_loo.native_description | html %]
                        [% ELSE %]
                            [% languages_loo.rfc4646_subtag | html %]
                        [% END %]
                    </a></li>
                [% END %]
        [% END %]
            [% END %]
            [% END %]

        [% END %]
        </ul>
        </div>
        </div>
    [% END %]
[% END %]
    <span id="audio-alert"></span>
    [% IF ( footerjs ) %]
        [% INCLUDE js_includes.inc %]
        [% jsinclude | $raw # Parse the page template's JavaScript block if necessary %]
    [% END %]
    </body>
[% KohaPlugins.get_plugins_intranet_js | $raw %]
</html>
