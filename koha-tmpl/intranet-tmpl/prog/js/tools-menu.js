$(document).ready(function () {
    var path = location.pathname.substring(1);
    if (
        path.indexOf("labels") >= 0 &&
        path.indexOf("spine") < 0 &&
        path.indexOf("barcode") < 0
    ) {
        $('#tools-menu a[href$="/cgi-bin/koha/labels/label-home.pl"]').addClass(
            "current"
        );
    } else if (path.indexOf("patroncards") >= 0) {
        $('#tools-menu a[href$="/cgi-bin/koha/patroncards/home.pl"]').addClass(
            "current"
        );
    } else if (path.indexOf("clubs") >= 0) {
        $('#tools-menu a[href$="/cgi-bin/koha/clubs/clubs.pl"]').addClass(
            "current"
        );
    } else if (path.indexOf("patron_lists") >= 0) {
        $(
            '#tools-menu a[href$="/cgi-bin/koha/patron_lists/lists.pl"]'
        ).addClass("current");
    } else if (path.indexOf("rotating_collections") >= 0) {
        $(
            '#tools-menu a[href$="/cgi-bin/koha/rotating_collections/rotatingCollections.pl"]'
        ).addClass("current");
    } else if ((path + location.search).indexOf("batchMod.pl?del=1") >= 0) {
        $(
            '#tools-menu a[href$="/cgi-bin/koha/tools/batchMod.pl?del=1"]'
        ).addClass("current");
    } else if (path.indexOf("quotes-upload.pl") >= 0) {
        $('#tools-menu a[href$="/cgi-bin/koha/tools/quotes.pl"]').addClass(
            "current"
        );
    } else if (path.indexOf("stockrotation") >= 0) {
        $(
            '#tools-menu a[href$="/cgi-bin/koha/tools/stockrotation.pl"]'
        ).addClass("current");
    } else if (path.indexOf("plugins") >= 0) {
        $(
            '#tools-menu a[href$="/cgi-bin/koha/plugins/plugins-home.pl?method=tool"]'
        ).addClass("current");
    } else if (path.indexOf("page.pl") >= 0) {
        $(
            '#tools-menu a[href$="/cgi-bin/koha/tools/additional-contents.pl?category=pages"]'
        ).addClass("current");
    } else if (path.indexOf("/tags/") >= 0) {
        $('#tools-menu a[href$="/cgi-bin/koha/tags/review.pl"]').addClass(
            "current"
        );
    }
});
