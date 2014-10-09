[% UNLESS ( is_popup ) %]
    [% IF ( opaccredits ) %]
        <div class="container-fluid">
            <div class="row-fluid">
                <div class="span12">
                    <div id="opaccredits">
                        [% opaccredits %]
                    </div>
                </div>
            </div>
        </div>
    [% END #/ opaccredits %]

    [% IF ( OpacKohaUrl ) %]
        <div class="container-fluid">
            <div class="row-fluid">
                <div class="span12">
                    <div id="koha_url" class="clearfix">
                        <p>Powered by
                        [% IF template.name.match('opac-main.tt') %]
                            <a class="koha_url" href="http://koha-community.org">Koha</a>
                        [% ELSE %]
                            <a class="koha_url" rel="nofollow" href="http://koha-community.org">Koha</a>
                        [% END %]</p>
                    </div>
                </div> <!-- /.span12 -->
            </div> <!-- /.row-fluid -->
        </div> <!-- /.container-fluid -->
    [% END # / OpacKohaUrl %]

</div> <!-- / #wrap in masthead.inc -->

    [% IF ( opaclanguagesdisplay ) %]
        [% IF ( languages_loop && opaclanguagesdisplay ) %]
            [% UNLESS ( one_language_enabled ) %]
                <div id="changelanguage" class="navbar navbar-fixed-bottom navbar-static-bottom">
                    <div class="navbar-inner">
                        <ul id="i18nMenu" class="nav">
                            <li><p class="lang navbar-text"><strong>Languages:&nbsp;</strong></p></li>
                            [% FOREACH languages_loo IN languages_loop %]
                                [% IF ( languages_loo.group_enabled ) %]
                                    [% IF ( languages_loo.plural ) %]
                                        <li class="dropdown">
                                            <a data-toggle="dropdown" class="dropdown-toggle sublangs" id="show[% languages_loo.rfc4646_subtag %]" href="#">[% IF ( languages_loo.native_description ) %][% languages_loo.native_description %][% ELSE %][% languages_loo.rfc4646_subtag %][% END %] <b class="caret"></b></a>
                                                <ul id="sub[% languages_loo.rfc4646_subtag %]" class="dropdown-menu">
                                                    [% FOREACH sublanguages_loo IN languages_loo.sublanguages_loop %]
                                                        [% IF ( sublanguages_loo.enabled ) %]
                                                            [% IF ( sublanguages_loo.sublanguage_current ) %]
                                                                <li> <p>[% sublanguages_loo.native_description %] [% sublanguages_loo.script_description %] [% sublanguages_loo.region_description %] [% sublanguages_loo.variant_description %] ([% sublanguages_loo.rfc4646_subtag %])</p></li>
                                                            [% ELSE %]
                                                                <li><a href="/cgi-bin/koha/opac-changelanguage.pl?language=[% sublanguages_loo.rfc4646_subtag %]"> [% sublanguages_loo.native_description %] [% sublanguages_loo.script_description %] [% sublanguages_loo.region_description %] [% sublanguages_loo.variant_description %] ([% sublanguages_loo.rfc4646_subtag %])</a></li>
                                                            [% END %]
                                                        [% END # / IF sublanguages_loo.enabled %]
                                                    [% END # / FOREACH sublanguages_loo %]
                                                </ul>
                                        </li> <!-- / .more -->
                                    [% ELSE %]
                                        [% IF ( languages_loo.group_enabled ) %]
                                            [% IF ( languages_loo.current ) %]
                                                <li class="active"><p class="navbar-text">[% IF ( languages_loo.native_description ) %][% languages_loo.native_description %][% ELSE %][% languages_loo.rfc4646_subtag %][% END %]</p></li>
                                            [% ELSE %]
                                                <li><a href="/cgi-bin/koha/opac-changelanguage.pl?language=[% languages_loo.rfc4646_subtag %]">[% IF ( languages_loo.native_description ) %][% languages_loo.native_description %][% ELSE %][% languages_loo.rfc4646_subtag %][% END %]</a></li>
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
[% END # / UNLESS is_popup %]


<!-- JavaScript includes -->
<script type="text/javascript" src="[% interface %]/[% theme %]/lib/jquery/jquery.js"></script>
<script type="text/javascript" src="[% interface %]/[% theme %]/lib/jquery/jquery-ui.js"></script>
<script type="text/javascript">
// Resolve name collision between jQuery UI and Twitter Bootstrap
$.widget.bridge('uitooltip', $.ui.tooltip);
</script>
<script type="text/javascript" src="[% interface %]/[% theme %]/lib/bootstrap/js/bootstrap.min.js"></script>
<script type="text/javascript" src="[% interface %]/[% theme %]/js/global.js"></script>
<script type="text/javascript">
    Modernizr.load([
        // Test need for polyfill
        {
            test: window.matchMedia,
            nope: "[% interface %]/[% theme %]/lib/media.match.min.js"
        },
        // and then load enquire
        "[% interface %]/[% theme %]/lib/enquire.min.js",
        "[% interface %]/[% theme %]/js/script.js"
    ]);
</script>
[% IF ( OPACAmazonCoverImages || SyndeticsCoverImages ) %]
<script type="text/javascript">//<![CDATA[
        var NO_AMAZON_IMAGE = _("No cover image available");
    //]]>
</script>
<script type="text/javascript" src="[% interface %]/[% theme %]/js/amazonimages.js"></script>
[% END %]

<script type="text/javascript">
    //<![CDATA[
    var MSG_CONFIRM_AGAIN = _("Warning: Cannot be undone. Please confirm once again")
    var MSG_DELETE_SEARCH_HISTORY = _("Are you sure you want to delete your search history?");
    var MSG_NO_SUGGESTION_SELECTED = _("No suggestion was selected");
    [% IF Koha.Preference( 'opacbookbag' ) == 1 or Koha.Preference( 'virtualshelves' ) == 1 %]
        var MSG_BASKET_EMPTY = _("Your cart is currently empty");
        var MSG_RECORD_IN_BASKET = _("The item is already in your cart");
        var MSG_RECORD_ADDED = _("The item has been added to your cart");
        var MSG_RECORD_REMOVED = _("The item has been removed from your cart");
        var MSG_NRECORDS_ADDED = _(" item(s) added to your cart");
        var MSG_NRECORDS_IN_BASKET = _("already in your cart");
        var MSG_NO_RECORD_SELECTED = _("No item was selected");
        var MSG_NO_RECORD_ADDED = _("No item was added to your cart");
        var MSG_CONFIRM_DEL_BASKET = _("Are you sure you want to empty your cart?");
        var MSG_CONFIRM_DEL_RECORDS = _("Are you sure you want to remove the selected items?");
        var MSG_ITEM_IN_CART = _("In your cart");
        var MSG_IN_YOUR_CART = _("Items in your cart: ");
        var MSG_ITEM_NOT_IN_CART = _("Add to your cart");
        var MSG_NO_RECORD_SELECTED = _("No item was selected");
    [% END %]
    [% IF ( Koha.Preference( 'opacuserlogin' ) == 1 ) && ( Koha.Preference( 'TagsEnabled' ) == 1 ) %]
        var MSG_TAGS_DISABLED = _("Sorry, tags are not enabled on this system.");
        var MSG_TAG_ALL_BAD = _("Error! Your tag was entirely markup code.  It was NOT added.  Please try again with plain text.");
        var MSG_ILLEGAL_PARAMETER = _("Error! Illegal parameter");
        var MSG_TAG_SCRUBBED = _("Note: your tag contained markup code that was removed. The tag was added as ");
        var MSG_ADD_TAG_FAILED = _("Error! The add_tag operation failed on");
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
    [% IF ( OPACAmazonCoverImages || SyndeticsCoverImages ) %]
        $(window).load(function() {
            verify_images();
         });
    [% END %]
    [% IF ( opacuserjs ) %][% opacuserjs %][% END %]
    //]]>
</script>

[% IF Koha.Preference( 'opacbookbag' ) == 1 %]
    <script type="text/javascript" src="[% interface %]/[% theme %]/js/basket.js"></script>
[% ELSIF ( Koha.Preference( 'virtualshelves' ) == 1 ) %]
    <script type="text/javascript" src="[% interface %]/[% theme %]/js/basket.js"></script>
[% ELSE %]
    <script type="text/javascript">var readCookie;</script>
[% END %]

[% IF Koha.Preference( 'opacuserlogin' ) == 1 %][% IF Koha.Preference( 'TagsEnabled' ) == 1 %]<script type="text/javascript" src="[% interface %]/[% theme %]/js/tags.js"></script>[% END %][% ELSE %][% END %]
[% IF ( GoogleJackets ) %]
    <script type="text/javascript" src="[% interface %]/[% theme %]/js/google-jackets.js"></script>
    <script type="text/javascript">
        //<![CDATA[
        var NO_GOOGLE_JACKET = _("No cover image available");
        //]]>
    </script>
[% END %]
[% IF OpenLibraryCovers %]
    <script type="text/javascript" src="[% interface %]/[% theme %]/js/openlibrary.js"></script>
    <script type="text/javascript">
    //<![CDATA[
    var NO_OL_JACKET = _("No cover image available");
    //]]>
    </script>
[% END %]

[% IF OPACLocalCoverImages %]
    <script type="text/javascript" src="[% interface %]/[% theme %]/js/localcovers.js"></script>
    <script type="text/javascript">
    //<![CDATA[
    var NO_LOCAL_JACKET = _("No cover image available");
    //]]>
    </script>
[% END %]

[% IF ( BakerTaylorEnabled ) %]
    <script type="text/javascript" src="[% interface %]/[% theme %]/js/bakertaylorimages.js"></script>
    <script type="text/javascript">
        //<![CDATA[
        var NO_BAKERTAYLOR_IMAGE = _("No cover image available");
        $(window).load(function(){
            bt_verify_images();
        });
        //]]>
    </script>
[% END %]
[% IF ( GoogleIndicTransliteration ) %]
    <script type="text/javascript" src="http://www.google.com/jsapi"></script>
    <script type="text/javascript" src="[% interface %]/[% theme %]/js/googleindictransliteration.js"></script>
[% END %]
[% IF persona %]
    <script src="https://login.persona.org/include.js"></script>
    <script type="text/javascript">

    navigator.id.watch({
        loggedInUser: [% IF emailaddress && loggedinpersona %]'[% emailaddress %]'[% ELSE %]null[% END %],
        onlogin: function (assertion) {
            $.post('/cgi-bin/koha/svc/login',
                { assertion: assertion },
                function (data) {
                    window.location = '/cgi-bin/koha/opac-user.pl';
                }
            )
            .fail(function() { var errstr = _("Could not login, perhaps your Persona email does not match your Koha one");
                alert(errstr);
            });
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
[% END #  / IF persona %]
[% PROCESS jsinclude %]

</body>
</html>
