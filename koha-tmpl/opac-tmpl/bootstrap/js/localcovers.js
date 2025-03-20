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
    GetCoverFromBibnumber: function () {
        $("div[id^=local-thumbnail],span[id^=local-thumbnail]").each(
            function () {
                var mydiv = this;
                var message = document.createElement("span");
                $(message).attr("class", "no-image");
                $(message).html(__("No cover image available"));
                $(mydiv).parent().find(".no-image").remove();
                $(mydiv).append(message);
                var img = $("<img />")
                    .attr(
                        "src",
                        "/cgi-bin/koha/opac-image.pl?thumbnail=1&biblionumber=" +
                            $(mydiv).attr("class")
                    )
                    .load(function () {
                        this.setAttribute("class", "thumbnail");
                        if (
                            !this.complete ||
                            typeof this.naturalWidth == "undefined" ||
                            this.naturalWidth == 0
                        ) {
                            //IE HACK
                            try {
                                $(mydiv).append(img);
                                $(mydiv).children(".no-image").remove();
                            } catch (err) {
                                // Nothing
                            }
                        } else if (this.width > 1) {
                            // don't show the silly 1px "no image" img
                            $(mydiv).empty().append(img);
                            $(mydiv).children(".no-image").remove();
                        }
                    });
            }
        );
    },
    GetCoverFromItemnumber: function (uselink) {
        $("div[class^=local-thumbnail],span[class^=local-thumbnail]").each(
            function () {
                var mydiv = this;
                var message = document.createElement("span");
                var imagenumber = $(mydiv).data("imagenumber");
                var biblionumber = $(mydiv).data("biblionumber");
                $(message).attr("class", "no-image");
                $(message).html(__("No cover image available"));
                $(mydiv).parent().find(".no-image").remove();
                $(mydiv).append(message);
                var img = $("<img />")
                    .attr(
                        "src",
                        "/cgi-bin/koha/opac-image.pl?thumbnail=1&imagenumber=" +
                            imagenumber
                    )
                    .load(function () {
                        this.setAttribute("class", "thumbnail");
                        if (
                            !this.complete ||
                            typeof this.naturalWidth == "undefined" ||
                            this.naturalWidth == 0
                        ) {
                            //IE HACK
                            try {
                                $(mydiv).append(img);
                                $(mydiv).children(".no-image").remove();
                            } catch (err) {
                                // Nothing
                            }
                        } else if (this.width > 1) {
                            // don't show the silly 1px "no image" img
                            if (uselink) {
                                var a = $("<a />").attr(
                                    "href",
                                    "/cgi-bin/koha/opac-imageviewer.pl?imagenumber=" +
                                        imagenumber +
                                        "&biblionumber=" +
                                        biblionumber
                                );
                                $(a).append(img);
                                $(mydiv).empty().append(a);
                            } else {
                                $(mydiv).empty().append(img);
                            }
                            $(mydiv).children(".no-image").remove();
                        }
                    });
            }
        );
    },
};
