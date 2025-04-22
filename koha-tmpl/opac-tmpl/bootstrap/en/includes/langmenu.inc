[% IF ( context == "footer" ) -%]
    [% SET li_class = 'nav-item dropup' %]
    [% SET menu_id = 'footer_langmenu' %]
[% ELSE %]
    [% SET li_class = 'nav-item dropdown' %]
    [% SET menu_id = 'header_langmenu' %]
[% END %]
<div id="[% menu_id | html %]" class="langmenu">
    <ul class="navbar-nav">
        <li class="[% li_class | html %]">
            <a href="#" title="Switch languages" class="nav-link dropdown-toggle" id="langmenu" data-bs-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false"
                ><i class="fa fa-flag fa-fw fa-icon-[% context | html %]" aria-hidden="true"></i> <span class="langlabel">Languages</span> <b class="caret"></b
            ></a>
            [% IF ( context == "footer" ) -%]
                [% SET div_class = 'dropdown-menu' %]
            [% ELSE %]
                [% SET div_class = 'dropdown-menu dropdown-menu-end' %]
            [% END %]
            <div aria-labelledby="langmenu" role="menu" class="[% div_class | html %]">
                [% FOREACH languages_loo IN languages_loop %]
                    [% IF ( languages_loo.group_enabled ) %]
                        [% IF ( languages_loo.plural ) %]
                            [% FOREACH sublanguages_loo IN languages_loo.sublanguages_loop %]
                                [% IF ( sublanguages_loo.enabled ) %]
                                    [% IF ( sublanguages_loo.sublanguage_current ) %]
                                        <a class="dropdown-item" href="#" tabindex="-1" role="menuitem"
                                            >[% sublanguages_loo.native_description | html %] [% sublanguages_loo.script_description | html %] [% sublanguages_loo.region_description | html %]
                                            [% sublanguages_loo.variant_description | html %]&nbsp;<i class="fa fa-check" aria-hidden="true"></i
                                        ></a>
                                    [% ELSE %]
                                        <a class="dropdown-item" href="/cgi-bin/koha/opac-changelanguage.pl?language=[% sublanguages_loo.rfc4646_subtag | uri %]" tabindex="-1" role="menuitem">
                                            [% sublanguages_loo.native_description | html %] [% sublanguages_loo.script_description | html %] [% sublanguages_loo.region_description | html %]
                                            [% sublanguages_loo.variant_description | html %]</a
                                        >
                                    [% END # /IF ( sublanguages_loo.sublanguage_current ) %]
                                [% END # / IF sublanguages_loo.enabled %]
                            [% END # / FOREACH sublanguages_loo %]
                        [% ELSE %]
                            [% IF ( languages_loo.group_enabled ) %]
                                [% IF ( languages_loo.current ) %]
                                    <a class="dropdown-item menu-inactive" href="#" tabindex="-1" role="menuitem">
                                        [% IF ( languages_loo.native_description ) %]
                                            [% languages_loo.native_description | html %]
                                        [% ELSE %]
                                            [% languages_loo.rfc4646_subtag | html %]
                                        [% END %]&nbsp;<i class="fa fa-check" aria-hidden="true"></i>
                                    </a>
                                [% ELSE %]
                                    <a class="dropdown-item" href="/cgi-bin/koha/opac-changelanguage.pl?language=[% languages_loo.rfc4646_subtag | uri %]" tabindex="-1" role="menuitem">
                                        [% IF ( languages_loo.native_description ) %]
                                            [% languages_loo.native_description | html %]
                                        [% ELSE %]
                                            [% languages_loo.rfc4646_subtag | html %]
                                        [% END %]
                                    </a>
                                [% END # / IF ( languages_loo.current ) %]
                            [% END # / IF languages_loo.current %]
                        [% END # / IF ( languages_loo.plural ) %]
                    [% END # / IF ( languages_loo.group_enabled ) %]
                [% END # / FOREACH languages_loo IN languages_loop %]
            </div>
            <!-- /# .dropdown-menu -->
        </li>
        <!-- / .dropdown -->
        <li class="divider-vertical" aria-hidden="false" role="presentation"></li>
    </ul>
    <!-- /.navbar-nav -->
</div>
<!-- /#[menu_id] -->
