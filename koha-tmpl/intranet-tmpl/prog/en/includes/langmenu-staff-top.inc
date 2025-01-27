[% IF ( ( ! one_language_enabled ) && ( languages_loop ) && ( Koha.Preference('StaffLangSelectorMode') == 'both' || Koha.Preference('StaffLangSelectorMode') == 'top') ) %]
    <li class="nav-item dropdown">
        <a href="#" title="Switch languages" class="nav-link dropdown-toggle" id="langmenu" data-bs-toggle="dropdown" role="button"
            ><i class="fa fa-fw fa-flag" aria-hidden="true"></i> <span class="langlabel nav-link-text">Languages</span>
        </a>
        <ul aria-labelledby="langmenu" role="menu" class="dropdown-menu dropdown-menu-dark dropdown-menu-end">
            [% FOREACH languages_loo IN languages_loop.sort('rfc4646_subtag') %]
                [% IF ( languages_loo.group_enabled ) %]
                    [% IF ( languages_loo.plural ) %]
                        [% FOREACH sublanguages_loo IN languages_loo.sublanguages_loop %]
                            [% IF ( sublanguages_loo.enabled ) %]
                                [% IF ( sublanguages_loo.sublanguage_current ) %]
                                    <li role="presentation" class="nav-item">
                                        <a href="#" tabindex="-1" class="nav-link menu-inactive" role="menuitem"
                                            >[% sublanguages_loo.native_description | html %] [% sublanguages_loo.script_description | html %] [% sublanguages_loo.region_description | html %]
                                            [% sublanguages_loo.variant_description | html %]&nbsp;<i class="fa fa-check"></i
                                        ></a>
                                    </li>
                                [% ELSE %]
                                    <li role="presentation" class="nav-item">
                                        <a class="nav-link" href="/cgi-bin/koha/changelanguage.pl?language=[% sublanguages_loo.rfc4646_subtag | uri %]" tabindex="-1" role="menuitem">
                                            [% sublanguages_loo.native_description | html %] [% sublanguages_loo.script_description | html %] [% sublanguages_loo.region_description | html %]
                                            [% sublanguages_loo.variant_description | html %]</a
                                        >
                                    </li>
                                [% END %]
                            [% END # / IF sublanguages_loo.enabled %]
                        [% END # / FOREACH sublanguages_loo %]
                    [% ELSE %]
                        [% IF ( languages_loo.group_enabled ) %]
                            [% IF ( languages_loo.current ) %]
                                <li role="presentation" class="nav-item">
                                    <a class="nav-link menu-inactive" href="#" tabindex="-1" role="menuitem"
                                        >[% IF ( languages_loo.native_description ) %][% languages_loo.native_description | html %][% ELSE %][% languages_loo.rfc4646_subtag | html %][% END %]&nbsp;<i class="fa fa-check"></i
                                    ></a>
                                </li>
                            [% ELSE %]
                                <li role="presentation" class="nav-item">
                                    <a class="nav-link" href="/cgi-bin/koha/changelanguage.pl?language=[% languages_loo.rfc4646_subtag | uri %]" tabindex="-1" role="menuitem"
                                        >[% IF ( languages_loo.native_description ) %][% languages_loo.native_description | html %][% ELSE %][% languages_loo.rfc4646_subtag | html %][% END %]</a
                                    >
                                </li>
                            [% END %]
                        [% END # / IF languages_loo.current %]
                    [% END # / IF ( languages_loo.plural ) %]
                [% END # / IF ( languages_loo.group_enabled ) %]
            [% END # / FOREACH languages_loo IN languages_loop %]
        </ul>
        <!-- /# .dropdown-menu -->
    </li>
    <!-- / .dropdown -->
[% END # / IF opaclanguagedisplay %]
