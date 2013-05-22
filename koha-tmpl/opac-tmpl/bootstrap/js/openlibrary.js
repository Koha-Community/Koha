if (typeof KOHA == "undefined" || !KOHA) {
    var KOHA = {};
}

/**
 * A namespace for OpenLibrary related functions.
 */
KOHA.OpenLibrary = {


    /**
     * Search all:
     *    <div title="biblionumber" id="isbn" class="openlibrary-thumbnail"></div>
     * or
     *    <div title="biblionumber" id="isbn" class="openlibrary-thumbnail-preview"></div>
     * and run a search with all collected isbns to Open Library Book Search.
     * The result is asynchronously returned by OpenLibrary and catched by
     * olCallBack().
     */
    GetCoverFromIsbn: function() {
        var bibkeys = [];
        $("[id^=openlibrary-thumbnail]").each(function(i) {
            bibkeys.push("ISBN:" + $(this).attr("class")); // id=isbn
        });
        bibkeys = bibkeys.join(',');
        var scriptElement = document.createElement("script");
        scriptElement.setAttribute("id", "jsonScript");
        scriptElement.setAttribute("src",
            "http://openlibrary.org/api/books?bibkeys=" + escape(bibkeys) +
            "&callback=KOHA.OpenLibrary.olCallBack&jscmd=data");
        scriptElement.setAttribute("type", "text/javascript");
        document.documentElement.firstChild.appendChild(scriptElement);
    },

    /**
     * Add cover pages <div
     * and link to preview if div id is gbs-thumbnail-preview
     */
    olCallBack: function(booksInfo) {
        for (id in booksInfo) {
            var book = booksInfo[id];
            var isbn = id.substring(5);
            $("[id^=openlibrary-thumbnail]."+isbn).each(function() {
                var is_opacdetail = /openlibrary-thumbnail-preview/.exec($(this).attr("id"));
                var a = document.createElement("a");
                a.href = booksInfo.url;
                if (book.cover) {
                    var img = document.createElement("img");
                    if (is_opacdetail) {
                        img.src = book.cover.medium;
                        $(this).append(img);
                        $(this).append('<div class="results_summary">' + '<a href="' + book.url + '">Preview</a></div>');
                    } else {
                        img.src = book.cover.medium;
                        img.height = '110';
                        $(this).append(img);
                    }
                } else {
                    var message =  document.createElement("span");
                    $(message).attr("class","no-image");
                    $(message).html(NO_OL_JACKET);
                    $(this).append(message);
                }
            });
        }
    }
};
