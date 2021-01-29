[% USE raw %]
[% USE Koha %]
[% USE KohaNews %]
[%- USE KohaPlugins -%]
[% USE Asset %]
[% SET opaccredits = KohaNews.get( location => "opaccredits", lang => lang, library => branchcode ) %]
[% PROCESS 'html_helpers.inc' %]
[% UNLESS ( is_popup ) %]
    [% SET OpacLangSelectorMode = Koha.Preference('OpacLangSelectorMode') %]
    [% IF ( opaccredits ) %]
        <div class="container-fluid">
            <div class="row-fluid">
                <div id="opaccredits">
                    [% PROCESS koha_news_block news => opaccredits %]
                </div>
            </div>
        </div>
    [% END #/ opaccredits %]

    [% IF ( Koha.Preference('OPACReportProblem') && Koha.Preference('KohaAdminEmailAddress') ) || OpacKohaUrl %]
        <div class="container-fluid">
            <div class="row-fluid">
                <div class="span12">
                    [% IF Koha.Preference('OPACReportProblem') && Koha.Preference('KohaAdminEmailAddress') %]
                    <div id="report_a_problem" class="noprint" style="float:left;">
                        <a class="koha-url" href="/cgi-bin/koha/opac-reportproblem.pl">Report a problem</a>
                    </div>
                    [% END %]
                    [% IF OpacKohaUrl %]
                    <div id="koha_url" class="clearfix noprint">
                        <p>Powered by
                        [% IF template.name.match('opac-main.tt') %]
                            <a class="koha_url" href="http://koha-community.org">Koha</a>
                        [% ELSE %]
                            <a class="koha_url" rel="nofollow" href="http://koha-community.org">Koha</a>
                        [% END %]</p>
                    </div>
                    [% END %]
                </div> <!-- /.span12 -->
            </div> <!-- /.row-fluid -->
        </div> <!-- /.container-fluid -->
    [% END # / OPACReportProblem || OpacKohaUrl %]

</div> <!-- / #wrap in masthead.inc -->
[% IF OpacLangSelectorMode == 'both' || OpacLangSelectorMode == 'footer' %]
    [% IF ( opaclanguagesdisplay ) %]
        [% IF ( languages_loop && opaclanguagesdisplay ) %]
            [% UNLESS ( one_language_enabled ) %]
                <div id="changelanguage" class="navbar navbar-fixed-bottom navbar-static-bottom noprint">
                    <div class="navbar-inner">
                        <ul id="i18nMenu" class="nav">
                            <li><p class="lang navbar-text"><strong>Languages:&nbsp;</strong></p></li>
                            [% FOREACH languages_loo IN languages_loop %]
                                [% IF ( languages_loo.group_enabled ) %]
                                    [% IF ( languages_loo.plural ) %]
                                        <li class="dropdown">
                                            <a data-toggle="dropdown" class="dropdown-toggle sublangs" id="show[% languages_loo.rfc4646_subtag | html %]" href="#">[% IF ( languages_loo.native_description ) %][% languages_loo.native_description | html %][% ELSE %][% languages_loo.rfc4646_subtag | html %][% END %] <b class="caret"></b></a>
                                                <ul id="sub[% languages_loo.rfc4646_subtag | html %]" class="dropdown-menu">
                                                    [% FOREACH sublanguages_loo IN languages_loo.sublanguages_loop %]
                                                        [% IF ( sublanguages_loo.enabled ) %]
                                                            [% IF ( sublanguages_loo.sublanguage_current ) %]
                                                                <li> <p>[% sublanguages_loo.native_description | html %] [% sublanguages_loo.script_description | html %] [% sublanguages_loo.region_description | html %] [% sublanguages_loo.variant_description | html %] ([% sublanguages_loo.rfc4646_subtag | html %])</p></li>
                                                            [% ELSE %]
                                                                <li><a href="/cgi-bin/koha/opac-changelanguage.pl?language=[% sublanguages_loo.rfc4646_subtag | uri %]"> [% sublanguages_loo.native_description | html %] [% sublanguages_loo.script_description | html %] [% sublanguages_loo.region_description | html %] [% sublanguages_loo.variant_description | html %] ([% sublanguages_loo.rfc4646_subtag | html %])</a></li>
                                                            [% END %]
                                                        [% END # / IF sublanguages_loo.enabled %]
                                                    [% END # / FOREACH sublanguages_loo %]
                                                </ul>
                                        </li> <!-- / .more -->
                                    [% ELSE %]
                                        [% IF ( languages_loo.group_enabled ) %]
                                            [% IF ( languages_loo.current ) %]
                                                <li class="active"><p class="navbar-text">[% IF ( languages_loo.native_description ) %][% languages_loo.native_description | html %][% ELSE %][% languages_loo.rfc4646_subtag | html %][% END %]</p></li>
                                            [% ELSE %]
                                                <li><a href="/cgi-bin/koha/opac-changelanguage.pl?language=[% languages_loo.rfc4646_subtag | uri %]">[% IF ( languages_loo.native_description ) %][% languages_loo.native_description | html %][% ELSE %][% languages_loo.rfc4646_subtag | html %][% END %]</a></li>
                                            [% END %]
                                        [% END # / IF languages_loo.current %]
                                    [% END # / IF ( languages_loo.plural ) %]
                                [% END # / IF ( languages_loo.group_enabled ) %]
                            [% END # / FOREACH languages_loo IN languages_loop %]
                        </ul> <!-- / #i18menu -->
                    </div> <!-- / .navbar-inner -->
                </div> <!-- / #changelanguage -->
            [% END # / UNLESS ( one_language_enabled ) %]
        [% END # / IF ( languages_loop && opaclanguagesdisplay ) %]
    [% END # / IF opaclanguagesdisplay %]
[% END %]
[% END # / UNLESS is_popup %]


<!-- JavaScript includes -->
[% Asset.js("lib/jquery/jquery-3.4.1.min.js") | $raw %]
[% Asset.js("lib/jquery/jquery-migrate-3.1.0.min.js") | $raw %]
[% Asset.js("lib/jquery/jquery-ui-1.12.1.min.js") | $raw %]
<script>
// Resolve name collision between jQuery UI and Twitter Bootstrap
$.widget.bridge('uitooltip', $.ui.tooltip);
</script>
[% Asset.js("lib/bootstrap/js/bootstrap.min.js") | $raw %]
[% Asset.js("lib/fontfaceobserver.min.js") | $raw %]
[% Asset.js("js/global.js") | $raw %]
<script>
    Modernizr.load([
        // Test need for polyfill
        {
            test: window.matchMedia,
            nope: "[% Asset.url('lib/media.match.min.js') | $raw %]"
        },
        // and then load enquire
        "[% Asset.url('lib/enquire.min.js') | $raw %]",
        "[% Asset.url('js/script.js') | $raw %]",
    ]);

    // Fix for datepicker in a modal
    $.fn.modal.Constructor.prototype.enforceFocus = function () {};
</script>
[% IF ( OPACAmazonCoverImages || SyndeticsCoverImages ) %]
<script>//<![CDATA[
        var NO_AMAZON_IMAGE = _("No cover image available");
    //]]>
</script>
[% Asset.js("js/amazonimages.js") | $raw %]
[% END %]

<script>
    //<![CDATA[
    var MSG_CONFIRM_AGAIN = _("Warning: Cannot be undone. Please confirm once again")
    var MSG_DELETE_SEARCH_HISTORY = _("Are you sure you want to delete your search history?");
    var MSG_NO_SUGGESTION_SELECTED = _("No suggestion was selected");
    var MSG_SEARCHING = _("Searching %s...");
    var MSG_ERROR_SEARCHING_COLLECTION = _("Error searching %s collection");
    var MSG_NO_RESULTS_FOUND_IN_COLLECTION = _("No results found in the library's %s collection");
    var MSG_RESULTS_FOUND_IN_COLLECTION = _("Found %s results in the library's %s collection");
    var MSG_BY = _("by");
    var MSG_TYPE = _("Type");
    var MSG_NEXT = _("Next");
    var MSG_PREVIOUS = _("Previous");
    var MSG_CHECKOUTS = _("Checkouts");
    var MSG_NO_CHECKOUTS = _("No checkouts");
    var MSG_CHECK_OUT = _("Check out");
    var MSG_CHECK_OUT_CONFIRM = _("Are you sure you want to check out this item?");
    var MSG_CHECKED_OUT_UNTIL = _("Checked out until %s");
    var MSG_CHECK_IN = _("Check in");
    var MSG_CHECK_IN_CONFIRM = _("Are you sure you want to return this item?");
    var MSG_NO_CHECKOUTS = _("No checkouts");
    var MSG_DOWNLOAD = _("Download");
    var MSG_HOLDS = _("Holds");
    var MSG_NO_HOLDS = _("No holds");
    var MSG_PLACE_HOLD = _("Place hold");
    var MSG_CANCEL_HOLD = _("Cancel");
    var MSG_CANCEL_HOLD_CONFIRM = _("Are you sure you want to cancel this hold?");
    var MSG_ON_HOLD = _("On hold");

    [% IF ( Koha.Preference( 'opacuserlogin' ) == 1 ) && ( Koha.Preference( 'TagsEnabled' ) == 1 ) %]
        var MSG_TAGS_DISABLED = _("Sorry, tags are not enabled on this system.");
        var MSG_TAG_ALL_BAD = _("Error! Your tag was entirely markup code.  It was NOT added.  Please try again with plain text.");
        var MSG_ILLEGAL_PARAMETER = _("Error! Illegal parameter");
        var MSG_TAG_SCRUBBED = _("Note: your tag contained markup code that was removed. The tag was added as ");
        var MSG_ADD_TAG_FAILED = _("Error! Adding tags failed at");
        var MSG_ADD_TAG_FAILED_NOTE = _("Note: you can only tag an item with a given term once.  Check 'My Tags' to see your current tags.");
        var MSG_DELETE_TAG_FAILED = _("Error! You cannot delete the tag");
        var MSG_DELETE_TAG_FAILED_NOTE = _("Note: you can only delete your own tags.")
        var MSG_LOGIN_REQUIRED = _("You must be logged in to add tags.");
        var MSG_TAGS_ADDED = _("Tags added: ");
        var MSG_TAGS_DELETED = _("Tags added: ");
        var MSG_TAGS_ERRORS = _("Errors: ");
        var MSG_MULTI_ADD_TAG_FAILED = _("Unable to add one or more tags.");
        var MSG_NO_TAG_SPECIFIED = _("No tag was specified.");
    [% END %]
    [% IF ( Koha.Preference('OverDriveClientKey') && Koha.Preference('OverDriveClientSecret') ) %]
        var MSG_OVERDRIVE_LOGIN = _("Log in to your OverDrive account");
        var MSG_OVERDRIVE_LINK = _( "OverDrive account page" );
        var MSG_OVERDRIVE_LOGOUT = _("Log out from your OverDrive account");
        var MSG_OVERDRIVE_CHECKEDOUT_UNTIL = _( "Checked out until: " );
        var MSG_OVERDRIVE_ACCESS_ONLINE = _("Access online");
        var MSG_OVERDRIVE_DOWNLOAD_AS = _( "Download as: " );
        var MSG_OVERDRIVE_CANNOT_CHECKOUT = _("Item cannot be checked out. There are no available formats");
    [% END %]
    [% IF OpenLibraryCovers || OpenLibrarySearch %]
        var NO_OL_JACKET = _("No cover image available");
        var OL_PREVIEW = _("Preview");
    [% END %]
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
    $(".clearsh").on("click", function(){
        return confirmDelete(MSG_DELETE_SEARCH_HISTORY);
    });
    //]]>
</script>

[% IF Koha.Preference( 'opacbookbag' ) == 1 %]
    [% Asset.js("js/basket.js") | $raw %]
[% ELSIF ( Koha.Preference( 'virtualshelves' ) == 1 ) %]
    [% Asset.js("js/basket.js") | $raw %]
[% ELSE %]
    <script>var readCookie;</script>
[% END %]

[% IF Koha.Preference( 'opacuserlogin' ) == 1 %][% IF Koha.Preference( 'TagsEnabled' ) == 1 %][% Asset.js("js/tags.js") | $raw %][% END %][% ELSE %][% END %]
[% IF ( GoogleJackets ) %]
    [% Asset.js("js/google-jackets.js") | $raw %]
    <script>
        //<![CDATA[
        var NO_GOOGLE_JACKET = _("No cover image available");
        //]]>
    </script>
[% END %]
[% IF ( Koha.Preference('OpacCoce') && Koha.Preference('CoceProviders') ) %]
    [% Asset.js("js/coce.js") | $raw %]
    <script>
        //<![CDATA[
        var NO_COCE_JACKET = _("No cover image available");
        //]]>
    </script>
[% END %]

[% IF OPACLocalCoverImages %]
    [% Asset.js("js/localcovers.js") | $raw %]
    <script>
    //<![CDATA[
    var NO_LOCAL_JACKET = _("No cover image available");
    //]]>
    </script>
[% END %]

[% IF ( BakerTaylorEnabled ) %]
    [% Asset.js("js/bakertaylorimages.js") | $raw %]
    <script>
        //<![CDATA[
        var NO_BAKERTAYLOR_IMAGE = _("No cover image available");
        $(window).load(function(){
            bt_verify_images();
        });
        //]]>
    </script>
[% END %]

[% IF Koha.Preference( 'OpacNewsLibrarySelect' ) %]
<script>
    $("#news-branch-select").change(function() {
        $( "#news-branch-select" ).submit();
    });
</script>
[% END %]

[% IF Koha.Preference('RecordedBooksClientSecret') && Koha.Preference('RecordedBooksLibraryID') %]
<script>
  var SPINNER_THROBBER = "[% interface | html %]/lib/jquery/plugins/themes/classic/throbber.gif";
</script>
[% END %]

[% Asset.js("lib/jquery/plugins/jquery.cookie.min.js") | $raw %]
<script>
$(document).ready(function() {
    if($('#searchsubmit').length) {
        $(document).on("click", '#searchsubmit', function(e) {
            jQuery.removeCookie("form_serialized", { path: '/'});
            jQuery.removeCookie("form_serialized_limits", { path: '/'});
            jQuery.removeCookie("num_paragraph", { path: '/'});
            jQuery.removeCookie("search_path_code", { path: '/'});
        });
    }
});
</script>
[% PROCESS jsinclude %]
[% IF ( Koha.Preference('OPACUserJS') ) %]
    <script>
        [% Koha.Preference('OPACUserJS') | $raw %]
    </script>
[% END %]
[% IF SCO_login %]
    [% SET SCOUserJS = Koha.Preference('SCOUserJS') %]
    [% IF ( SCOUserJS ) %]
        <script>
            //<![CDATA[
            [% SCOUserJS | $raw %]
            //]]>
        </script>
    [% END %]
[% END %]
[% KohaPlugins.get_plugins_opac_js | $raw %]
</body>
</html>
