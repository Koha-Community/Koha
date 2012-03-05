        </div>

[% IF ( languages_loop ) %]
    [% UNLESS ( one_language_enabled ) %]
        <div id="changelanguage" class="ft">
        <ul id="i18nMenu" class="footermenu">
        [% FOREACH languages_loo IN languages_loop %]

            [% IF ( languages_loo.group_enabled ) %]
            [% IF ( languages_loo.plural ) %]
            <li class="more"><a class="sublangs" id="show[% languages_loo.rfc4646_subtag %]" href="#">[% languages_loo.native_description %] ([% languages_loo.rfc4646_subtag %])</a><div id="sub[% languages_loo.rfc4646_subtag %]">
            <div class="bd"><ul>
            [% FOREACH sublanguages_loo IN languages_loo.sublanguages_loop %]
		[% IF ( sublanguages_loo.enabled ) %]
                [% IF ( sublanguages_loo.sublanguage_current ) %]
                    <li> <a href="#">[% sublanguages_loo.native_description %] [% sublanguages_loo.script_description %] [% sublanguages_loo.region_description %] [% sublanguages_loo.variant_description %] ([% sublanguages_loo.rfc4646_subtag %])</a></li>
                [% ELSE %]
                <li><a href="/cgi-bin/koha/changelanguage.pl?language=[% sublanguages_loo.rfc4646_subtag %]"> [% sublanguages_loo.native_description %] [% sublanguages_loo.script_description %] [% sublanguages_loo.region_description %] [% sublanguages_loo.variant_description %] ([% sublanguages_loo.rfc4646_subtag %])</a></li>
		[% END %]
                [% END %]

            [% END %]
            </ul></div></div></li>

            [% ELSE %]
	    	[% IF ( languages_loo.group_enabled ) %]
                [% IF ( languages_loo.current ) %]
                    <li>[% IF ( languages_loo.native_description ) %][% languages_loo.native_description %][% ELSE %][% languages_loo.rfc4646_subtag %][% END %]</li>
                [% ELSE %]
                    <li><a href="/cgi-bin/koha/changelanguage.pl?language=[% languages_loo.rfc4646_subtag %]">[% IF ( languages_loo.native_description ) %][% languages_loo.native_description %][% ELSE %][% languages_loo.rfc4646_subtag %][% END %]</a></li>
                [% END %]
		[% END %]
            [% END %]
            [% END %]

        [% END %]
        </ul>
        </div>
    [% END %]
[% END %]
    </body>
</html>
