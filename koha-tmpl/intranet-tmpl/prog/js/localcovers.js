/* global __ */

if (typeof KOHA == "undefined" || !KOHA) {
    var KOHA = {};
}

/**
 * A namespace for local cover related functions.
 */
KOHA.LocalCover = {
    /**
     * Search all:
     *    <div title="biblionumber" id="isbn" class="openlibrary-thumbnail"></div>
     * or
     *    <div title="biblionumber" id="isbn" class="openlibrary-thumbnail-preview"></div>
     * and run a search with all collected isbns to Open Library Book Search.
     * The result is asynchronously returned by OpenLibrary and caught by
     * olCallBack().
     */
    GetCoverFromBibnumber: function (uselink) {
        var mydiv = $("#local-thumbnail-preview");
        var biblionumber = mydiv.data("biblionumber");
        var img = document.createElement("img");
        img.src =
            "/cgi-bin/koha/catalogue/image.pl?thumbnail=1&biblionumber=" +
            biblionumber;
        img.onload = function () {
            // image dimensions can't be known until image has loaded
            if (img.complete != null && !img.complete) {
                mydiv.remove();
            }
        };
        if (uselink) {
            var a = $("<a />").attr(
                "href",
                "/cgi-bin/koha/catalogue/imageviewer.pl?biblionumber=" +
                    $(mydiv).attr("class")
            );
            $(a).append(img);
            mydiv.append(a);
        } else {
            mydiv.append(img);
        }
    },
};
