[%# Following on one line for translatability %]
[% IF ( ( opaclanguagesdisplay ) && ( ! one_language_enabled ) && ( languages_loop ) && ( OpacLangSelectorMode == 'both' || OpacLangSelectorMode == 'top') ) %]
<li class="dropdown">
  <a href="#" title="Switch languages" class="dropdown-toggle" id="langmenu" data-toggle="dropdown" role="button"><i class="icon-flag icon-white"></i> <span class="langlabel">Languages</span> <b class="caret"></b></a>
    <ul aria-labelledby="langmenu" role="menu" class="dropdown-menu">
    [% FOREACH languages_loo IN languages_loop.sort('rfc4646_subtag') %]
        [% IF ( languages_loo.group_enabled ) %]
            [% IF ( languages_loo.plural ) %]
                [% FOREACH sublanguages_loo IN languages_loo.sublanguages_loop %]
                    [% IF ( sublanguages_loo.enabled ) %]
                        [% IF ( sublanguages_loo.sublanguage_current ) %]
                         <li role="presentation"> <a href="#" tabindex="-1" role="menuitem">[% sublanguages_loo.native_description %] [% sublanguages_loo.script_description %] [% sublanguages_loo.region_description %] [% sublanguages_loo.variant_description %]&nbsp;<i class="icon-ok"></i></a></li>
                        [% ELSE %]
                        <li role="presentation"><a href="/cgi-bin/koha/opac-changelanguage.pl?language=[% sublanguages_loo.rfc4646_subtag %]"  tabindex="-1" role="menuitem"> [% sublanguages_loo.native_description %] [% sublanguages_loo.script_description %] [% sublanguages_loo.region_description %] [% sublanguages_loo.variant_description %]</a></li>
                        [% END %]
                    [% END # / IF sublanguages_loo.enabled %]
                [% END # / FOREACH sublanguages_loo %]
            [% ELSE %]
                [% IF ( languages_loo.group_enabled ) %]
                    [% IF ( languages_loo.current ) %]
                    <li role="presentation"><a href="#" tabindex="-1" class="menu-inactive" role="menuitem">[% IF ( languages_loo.native_description ) %][% languages_loo.native_description %][% ELSE %][% languages_loo.rfc4646_subtag %][% END %]&nbsp;<i class="icon-ok"></i></a></li>
                    [% ELSE %]
                    <li role="presentation"><a href="/cgi-bin/koha/opac-changelanguage.pl?language=[% languages_loo.rfc4646_subtag %]"  tabindex="-1" role="menuitem">[% IF ( languages_loo.native_description ) %][% languages_loo.native_description %][% ELSE %][% languages_loo.rfc4646_subtag %][% END %]</a></li>
                    [% END %]
                [% END # / IF languages_loo.current %]
            [% END # / IF ( languages_loo.plural ) %]
        [% END # / IF ( languages_loo.group_enabled ) %]
    [% END # / FOREACH languages_loo IN languages_loop %]
    </ul> <!-- /# .dropdown-menu -->
</li> <!-- / .dropdown -->
[% END # / IF opaclanguagedisplay %]
