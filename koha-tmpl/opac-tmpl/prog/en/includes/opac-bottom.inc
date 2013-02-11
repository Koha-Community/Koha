[% IF ( opaccredits ) %]
	<div class="ft">
            [% opaccredits %]
        </div>
[% END %]
</div>

[% IF ( opaclanguagesdisplay || OpacKohaUrl ) %]
    [% IF ( languages_loop && opaclanguagesdisplay ) %]
        [% UNLESS ( one_language_enabled ) %]
            <div id="changelanguage" class="ft">
            <div class="lang" style="float:left;padding: 0.1em 0;"><strong>Languages:&nbsp;</strong></div>
            <ul id="i18nMenu" class="footermenu">
            [% FOREACH languages_loo IN languages_loop %]

                [% IF ( languages_loo.group_enabled ) %]
                [% IF ( languages_loo.plural ) %]
                <li class="more" style="float:left;"><a class="sublangs" id="show[% languages_loo.rfc4646_subtag %]" href="#">[% IF ( languages_loo.native_description ) %][% languages_loo.native_description %][% ELSE %][% languages_loo.rfc4646_subtag %][% END %]</a><div id="sub[% languages_loo.rfc4646_subtag %]">
                <div class="bd"><ul>
                [% FOREACH sublanguages_loo IN languages_loo.sublanguages_loop %]
            [% IF ( sublanguages_loo.enabled ) %]
                    [% IF ( sublanguages_loo.sublanguage_current ) %]
                        <li> [% sublanguages_loo.native_description %] [% sublanguages_loo.script_description %] [% sublanguages_loo.region_description %] [% sublanguages_loo.variant_description %] ([% sublanguages_loo.rfc4646_subtag %])</li>
                    [% ELSE %]
                    <li><a href="/cgi-bin/koha/changelanguage.pl?language=[% sublanguages_loo.rfc4646_subtag %]"> [% sublanguages_loo.native_description %] [% sublanguages_loo.script_description %] [% sublanguages_loo.region_description %] [% sublanguages_loo.variant_description %] ([% sublanguages_loo.rfc4646_subtag %])</a></li>
            [% END %]
                    [% END %]

                [% END %]
                </ul></div></div></li>

                [% ELSE %]
                [% IF ( languages_loo.group_enabled ) %]
                    [% IF ( languages_loo.current ) %]
                        <li style="float:left;">[% IF ( languages_loo.native_description ) %][% languages_loo.native_description %][% ELSE %][% languages_loo.rfc4646_subtag %][% END %]</li>
                    [% ELSE %]
                        <li style="float:left;"><a href="/cgi-bin/koha/changelanguage.pl?language=[% languages_loo.rfc4646_subtag %]">[% IF ( languages_loo.native_description ) %][% languages_loo.native_description %][% ELSE %][% languages_loo.rfc4646_subtag %][% END %]</a></li>
                    [% END %]
            [% END %]
                [% END %]
                [% END %]

            [% END %]
            </ul>
            </div>
        [% END %]
    [% END %]

    [% IF ( OpacKohaUrl ) %]
    <span class="koha_url">
        Powered by <strong>
        [% IF template.name.match('opac-main.tt') %]
            <a class="koha_url" href="http://koha-community.org">Koha</a>
        [% ELSE %]
            <a class="koha_url" rel="nofollow" href="http://koha-community.org">Koha</a>
        [% END %]
        </strong>&nbsp;&nbsp;
    </span>
    [% END %]

[% END %]

[% IF persona %]
<script src="https://login.persona.org/include.js"></script>
<script type="text/javascript" language="javascript">

navigator.id.watch({
    loggedInUser: [% IF emailaddress %]'[% emailaddress %]'[% ELSE %]null[% END %],
    onlogin: function (assertion) {
        $.post('/cgi-bin/koha/svc/login',
            { assertion: assertion },
            function (data) {
                window.location = '/cgi-bin/koha/opac-user.pl';
            }
        );
    },
    onlogout: function () {
        window.location = '/cgi-bin/koha/opac-main.pl?logout.x=1';
    }
});

var signinLink = document.getElementById('browserid');

if (signinLink) {
    signinLink.onclick = function(evt) {
        // Requests a signed identity assertion from the user.
        navigator.id.request({
            siteName: "[% LibraryName | html %]",
            returnTo: '/cgi-bin/koha/opac-user.pl',
            oncancel: function() { alert('user refuses to share identity.'); }
            });
        };
}

</script>
[% END %]


</body>
</html>
