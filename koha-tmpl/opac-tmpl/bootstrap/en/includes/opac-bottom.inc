[% USE raw %]
[% USE Koha %]
[% USE Branches %]
[% USE AdditionalContents %]
[%- USE KohaPlugins -%]
[% USE Asset %]
[% SET opaccredits = AdditionalContents.get( location => "opaccredits", lang => lang, library => logged_in_user.branchcode || default_branch ) %]
[% PROCESS 'html_helpers.inc' %]
[% IF Koha.Preference( 'CookieConsent' ) %]
    [% USE JSConsents %]
[% END %]
[% UNLESS ( is_popup ) %]
    [% SET OpacLangSelectorMode = Koha.Preference('OpacLangSelectorMode') %]
    [% IF ( opaccredits ) %]
        <div class="container-fluid">
            <div class="row">
                <div class="col"> [% PROCESS koha_news_block news => opaccredits %] </div>
            </div>
        </div>
    [% END #/ opaccredits %]
    <!-- prettier-ignore-start -->
    </div> <!-- / #wrapper in masthead.inc -->
    <!-- prettier-ignore-end -->

    [% IF ( Koha.Preference('OPACReportProblem') && Koha.Preference('KohaAdminEmailAddress') ) || Koha.Preference( 'CookieConsent' ) || OpacKohaUrl || ( ( opaclanguagesdisplay ) && ( ! one_language_enabled ) && ( languages_loop ) && ( OpacLangSelectorMode == 'both' || OpacLangSelectorMode == 'footer') ) %]
        <footer id="changelanguage" class="navbar navbar-expand navbar-light bg-light noprint">
            <div class="container-fluid">
                <div class="collapse navbar-collapse">
                    [%# Following on one line for translatability %]
                    [% IF ( ( opaclanguagesdisplay ) && ( ! one_language_enabled ) && ( languages_loop ) && ( OpacLangSelectorMode == 'both' || OpacLangSelectorMode == 'footer') ) %]
                        [% context = "footer" %]
                        [% INCLUDE 'langmenu.inc' %]
                    [% END # / IF opaclanguagedisplay %]

                    <div class="navbar-nav flex-grow-1">
                        [% IF Koha.Preference('OPACReportProblem') && Koha.Preference('KohaAdminEmailAddress') %]
                            <a id="report_a_problem" class="nav-link" href="/cgi-bin/koha/opac-reportproblem.pl">
                                <i class="fa fa-warning fa-fw fa-icon-footer" aria-hidden="true"></i>
                                <span class="report_a_problem_text">Report a problem</span>
                            </a>
                        [% END %]

                        [% IF Koha.Preference( 'CookieConsent' ) %]
                            <a id="cookieConsentFooter" class="nav-link" href="#">
                                <i class="fa fa-cookie fa-fw fa-icon-footer" aria-hidden="true"></i>
                                <span class="cookieConsentFooter_text">Cookies</span>
                            </a>
                        [% END %]
                    </div>
                    [% IF OpacKohaUrl %]
                        <div class="navbar-nav">
                            <a id="koha_url" class="nav-link koha_url" href="https://koha-community.org">
                                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 16 16">
                                    <path
                                        fill="currentColor"
                                        d="M7.394.75c.82-.45 1.75-.72 2.69-.75.5.015.99.1 1.45.27.92.35 1.68 1.05 2.15 1.9.53.865.76 1.875.87 2.875.25 3.315-.98 6.635-3.07 9.18-.825.82-1.835 1.52-3 1.735-.96.135-2-.07-2.775-.675-.48-.365-.67-1-.63-1.575.425.6 1.12 1.015 1.86 1.035.675.03 1.35-.275 1.8-.765.75-.825.835-2.21.12-3.08-.325-.375-.7-.715-1.15-.95-.44-.265-.95-.38-1.46-.45-.93-.06-1.9.11-2.72.57a3.22 3.22 0 0 0-1.565 2.15c-.2.7-.125 1.43-.05 2.14-.31-.81-.43-1.67-.5-2.53v-.64c.12-3.13 1.43-6.2 3.53-8.515.725-.75 1.53-1.43 2.45-1.92Zm0 0"
                                        style="stroke-width:.500008"
                                    />
                                </svg>
                                <span class="koha_url_text">Powered by Koha</span>
                            </a>
                        </div>
                    [% END # /IF OpacKohaUrl %]
                </div>
                <!-- /.collapse.navbar-collapse -->
            </div>
            <!-- /.container-fluid -->
        </footer>
        <!-- / #changelanguage -->
    [% END # /IF OpacLangSelectorMode == 'both' || OpacLangSelectorMode == 'footer' %]
[% END # / UNLESS is_popup %]

[% IF Koha.Preference( 'OpacTrustedCheckout' ) %]
    [% INCLUDE 'modals/checkout.inc' %]
[% END %]

<!-- CookieConsentedJS code that may run -->
[% IF Koha.Preference( 'CookieConsent' ) && JSConsents.all('opacConsent').size %]
    [% consents = JSConsents.all('opacConsent') %]
    [% FOREACH consent IN consents %]
        <div
            class="consentCode"
            style="display:none"
            aria-hidden="true"
            data-consent-id="[% consent.id | html %]"
            data-consent-code="[% consent.code | html %]"
            data-consent-match-pattern="[% consent.matchPattern | html %]"
            data-consent-cookie-domain="[% consent.cookieDomain | html %]"
            data-consent-cookie-path="[% consent.cookiePath | html %]"
            data-requires-consent="[% consent.opacConsent ? 'true' : 'false' | html %]"
        ></div>
    [% END %]
[% END %]

<!-- JavaScript includes -->
[% Asset.js("lib/jquery/jquery-3.6.0.min.js") | $raw %]
[% Asset.js("lib/jquery/jquery-migrate-3.3.2.min.js") | $raw %]
[% Asset.js("lib/bootstrap/js/bootstrap.bundle.min.js") | $raw %]
[% Asset.js("lib/fontfaceobserver/fontfaceobserver.min.js") | $raw %]
[% Asset.js("lib/enquire/enquire.min.js") | $raw %]
<script>
    let logged_in_user_id = "[% logged_in_user.borrowernumber | html %]";
</script>
[% Asset.js("js/global.js") | $raw %]
[% Asset.js("js/form-submit.js",{'type' => 'module'}) | $raw %]
[% IF ( OPACAmazonCoverImages || SyndeticsCoverImages ) %]
    [% Asset.js("js/amazonimages.js") | $raw %]
[% END %]
<script>
    [% IF (query_desc) %]
        var query_desc = "[% query_desc | html %]";
        var querystring = "[% querystring | html %]";
        var query_cgi = "[% query_cgi | html %]";
    [% END %]

    [% IF ( OPACAmazonCoverImages || SyndeticsCoverImages ) %]
        $(window).load(function() {
            verify_images();
         });
    [% END %]
    $(".print-large").on("click",function(){
        window.print();
        return false;
    });
    $(".addtoshelf").on("click",function(e){
        e.preventDefault();
        Dopop( this.href );
    });
    $("body").on("click", ".addtocart", function(e){
        e.preventDefault();
        var biblionumber = $(this).data("biblionumber");
        addRecord( biblionumber );
    });
    $("body").on("click", ".cartRemove", function(e){
        e.preventDefault();
        var biblionumber = $(this).data("biblionumber");
        delSingleRecord( biblionumber );
    });
</script>
[% IF Koha.Preference( 'opacbookbag' ) == 1 %]
    [% Asset.js("js/basket.js") | $raw %]
[% ELSIF ( Koha.Preference( 'virtualshelves' ) == 1 ) %]
    [% Asset.js("js/basket.js") | $raw %]
[% ELSE %]
    <script>
        var readCookie;
    </script>
[% END %]

[% IF Koha.Preference( 'opacuserlogin' ) == 1 %][% IF Koha.Preference( 'TagsEnabled' ) == 1 %][% Asset.js("js/tags.js") | $raw %][% END %][% END %]
[% IF ( GoogleJackets ) %]
    [% Asset.js("js/google-jackets.js") | $raw %]
[% END %]
[% IF ( Koha.Preference('OpacCoce') && Koha.Preference('CoceProviders') ) %]
    [% Asset.js("js/coce.js") | $raw %]
[% END %]

[% IF OPACLocalCoverImages %]
    [% Asset.js("js/localcovers.js") | $raw %]
[% END %]

[% IF ( BakerTaylorEnabled ) %]
    [% Asset.js("js/bakertaylorimages.js") | $raw %]
    <script>
        $(window).load(function () {
            bt_verify_images();
        });
    </script>
[% END %]

[% IF Koha.Preference( 'OpacNewsLibrarySelect' ) %]
    <script>
        $("#news-branch-select").change(function () {
            $("#news-branch-select").submit();
        });
    </script>
[% END %]

[% Asset.js("lib/js-cookie/js.cookie-3.0.1.min.js") | $raw %]
[% Asset.js("js/show-password-toggle.js") | $raw %]
<script>
    $(document).ready(function () {
        if ($("#searchsubmit").length) {
            $(document).on("click", "#searchsubmit", function (e) {
                Cookies.remove("form_serialized", { path: "/" });
                Cookies.remove("form_serialized_limits", { path: "/" });
                Cookies.remove("search_path_code", { path: "/" });
            });
        }
    });
</script>
[% INCLUDE 'js-date-format.inc' %]
[% INCLUDE 'js-biblio-format.inc' %]
[% PROCESS jsinclude %]
[% IF ( Koha.Preference('OPACUserJS') ) %]
    <script>
        [% Koha.Preference('OPACUserJS') | $raw %]
    </script>
[% END %]
[% IF Branches.GetBranchSpecificJS( Branches.GetLoggedInBranchcode() || default_branch) %]
    <script>
        [% Branches.GetBranchSpecificJS( Branches.GetLoggedInBranchcode() || default_branch) | $raw %]
    </script>
[% END %]
[% IF SCO_login %]
    [% SET SCOUserJS = Koha.Preference('SCOUserJS') %]
    [% IF ( SCOUserJS ) %]
        <script>
            [% SCOUserJS | $raw %]
        </script>
    [% END %]
[% END %]
[% IF Koha.Preference( 'OpacTrustedCheckout' ) %]
    [% Asset.js("js/modals/checkout.js") | $raw %]
[% END %]
[% IF Koha.Preference( 'CookieConsent' ) %]
    [% Asset.js("js/cookieconsent.js") | $raw %]
[% END %]
[% KohaPlugins.get_plugins_opac_js | $raw %]
</body>
<!-- prettier-ignore-start -->
</html>
<!-- prettier-ignore-end -->
