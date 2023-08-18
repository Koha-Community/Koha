[%# Following on one line for translatability %]
[% IF ( ( opaclanguagesdisplay ) && ( ! one_language_enabled ) && ( languages_loop ) && ( OpacLangSelectorMode == 'both' || OpacLangSelectorMode == 'top') ) %]
    <div id="header_langmenu">
        <ul class="navbar-nav">
            <li class="dropdown">
              <a href="#" title="Switch languages" class="nav-link dropdown-toggle" id="langmenu" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false"><i class="fa fa-flag fa-icon-black" aria-hidden="true"></i> <span class="langlabel">Languages</span> <b class="caret"></b></a>
                <div aria-labelledby="langmenu" role="menu" class="dropdown-menu dropdown-menu-right">
                    [% FOREACH languages_loo IN languages_loop %]
                        [% IF ( languages_loo.group_enabled ) %]
                            [% IF ( languages_loo.plural ) %]
                                [% FOREACH sublanguages_loo IN languages_loo.sublanguages_loop %]
                                    [% IF ( sublanguages_loo.enabled ) %]
                                        [% IF ( sublanguages_loo.sublanguage_current ) %]
                                            <a class="dropdown-item" href="#" tabindex="-1" role="menuitem">[% sublanguages_loo.native_description | html %] [% sublanguages_loo.script_description | html %] [% sublanguages_loo.region_description | html %] [% sublanguages_loo.variant_description | html %]&nbsp;<i class="fa fa-check" aria-hidden="true"></i></a>
                                        [% ELSE %]
                                            <a class="dropdown-item" href="/cgi-bin/koha/opac-changelanguage.pl?language=[% sublanguages_loo.rfc4646_subtag | uri %]"  tabindex="-1" role="menuitem"> [% sublanguages_loo.native_description | html %] [% sublanguages_loo.script_description | html %] [% sublanguages_loo.region_description | html %] [% sublanguages_loo.variant_description | html %]</a>
                                        [% END # /IF ( sublanguages_loo.sublanguage_current ) %]
                                    [% END # / IF sublanguages_loo.enabled %]
                                [% END # / FOREACH sublanguages_loo %]
                            [% ELSE %]
                                [% IF ( languages_loo.group_enabled ) %]
                                    [% IF ( languages_loo.current ) %]
                                        <a class="dropdown-item" href="#" tabindex="-1" class="menu-inactive" role="menuitem">
                                            [% IF ( languages_loo.native_description ) %]
                                                [% languages_loo.native_description | html %]
                                            [% ELSE %]
                                                [% languages_loo.rfc4646_subtag | html %]
                                            [% END %]&nbsp;<i class="fa fa-check" aria-hidden="true"></i>
                                        </a>
                                    [% ELSE %]
                                        <a class="dropdown-item" href="/cgi-bin/koha/opac-changelanguage.pl?language=[% languages_loo.rfc4646_subtag | uri %]"  tabindex="-1" role="menuitem">
                                            [% IF ( languages_loo.native_description ) %]
                                                [% languages_loo.native_description | html %]
                                            [% ELSE %]
                                                [% languages_loo.rfc4646_subtag | html %]
                                            [% END %]
                                        </a>
                                    [% END # / IF ( languages_loo.current )%]
                                [% END # / IF languages_loo.current %]
                            [% END # / IF ( languages_loo.plural ) %]
                        [% END # / IF ( languages_loo.group_enabled ) %]
                    [% END # / FOREACH languages_loo IN languages_loop %]
                </div> <!-- /# .dropdown-menu -->
            </li> <!-- / .dropdown -->
        </ul> <!-- /.nav.pull-right -->
    </div> <!-- /#header_langmenu -->
[% END # / IF opaclanguagedisplay %]
