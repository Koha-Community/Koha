        </div>

[% IF ( languages_loop ) %]
    [% UNLESS ( one_language_enabled ) %]
        <div id="changelanguage" class="navbar navbar-fixed-bottom">
            <div class="navbar-inner">
        <ul id="i18nMenu" class="nav">
        [% FOREACH languages_loo IN languages_loop %]

            [% IF ( languages_loo.group_enabled ) %]
            [% IF ( languages_loo.plural ) %]
                <li class="dropdown"><a class="dropdown-toggle dropup" data-toggle="dropdown" id="show[% languages_loo.rfc4646_subtag %]" href="#">
                    [% IF ( languages_loo.native_description ) %]
                        [% languages_loo.native_description %]
                    [% ELSE %]
                        [% languages_loo.rfc4646_subtag %]
                    [% END %]
                    [% FOREACH sublanguages_loo IN languages_loo.sublanguages_loop %]
                        [% IF ( sublanguages_loo.enabled ) %]
                            [% IF ( sublanguages_loo.sublanguage_current ) %]
                                <span class="sublanguage-selected">([% sublanguages_loo.rfc4646_subtag %])</span>
                            [% END %]
                        [% END %]
                    [% END %]
                <span class="caret"></span></a>
            <ul id="sub[% languages_loo.rfc4646_subtag %]" class="dropdown-menu">
            [% FOREACH sublanguages_loo IN languages_loo.sublanguages_loop %]
        [% IF ( sublanguages_loo.enabled ) %]
                [% IF ( sublanguages_loo.sublanguage_current ) %]
                    <li class="navbar-text"> <a href="#" class="currentlanguage disabled">[% sublanguages_loo.native_description %] [% sublanguages_loo.script_description %] [% sublanguages_loo.region_description %] [% sublanguages_loo.variant_description %] ([% sublanguages_loo.rfc4646_subtag %])</a></li>
                [% ELSE %]
                <li><a href="/cgi-bin/koha/changelanguage.pl?language=[% sublanguages_loo.rfc4646_subtag %]"> [% sublanguages_loo.native_description %] [% sublanguages_loo.script_description %] [% sublanguages_loo.region_description %] [% sublanguages_loo.variant_description %] ([% sublanguages_loo.rfc4646_subtag %])</a></li>
        [% END %]
                [% END %]

            [% END %]
            </ul></li>

            [% ELSE %]
            [% IF ( languages_loo.group_enabled ) %]
                [% IF ( languages_loo.current ) %]
                    <li class="navbar-text">
                        [% IF ( languages_loo.native_description ) %]
                            <span class="currentlanguage">[% languages_loo.native_description %]</span>
                        [% ELSE %]
                            <span class="currentlanguage">[% languages_loo.rfc4646_subtag %]</span>
                        [% END %]
                    </li>
                [% ELSE %]
                    <li><a href="/cgi-bin/koha/changelanguage.pl?language=[% languages_loo.rfc4646_subtag %]">
                        [% IF ( languages_loo.native_description ) %]
                            [% languages_loo.native_description %]
                        [% ELSE %]
                            [% languages_loo.rfc4646_subtag %]
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
    </body>
</html>
