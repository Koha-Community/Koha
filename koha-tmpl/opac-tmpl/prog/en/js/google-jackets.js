if (typeof KOHA == "undefined" || !KOHA) {
    var KOHA = {};
}

/**
 * A namespace for Google related functions.
 */
KOHA.Google = {


    /**
     * Search all:
     *    <div title="biblionumber" id="isbn" class="gbs-thumbnail"></div>
     * and run a search with all collected isbns to Google Book Search.
     * The result is asynchronously returned by Google and catched by
     * gbsCallBack().
     */
    GetCoverFromIsbn: function() {
        var bibkeys = [];
        $("div [id^=gbs-thumbnail]").each(function(i) {
            bibkeys.push($(this).attr("class")); // id=isbn
        });
        bibkeys = bibkeys.join(',');
        var scriptElement = document.createElement("script");
        scriptElement.setAttribute("id", "jsonScript");
        scriptElement.setAttribute("src",
            "http://books.google.com/books?bibkeys=" + escape(bibkeys) +
            "&jscmd=viewapi&callback=KOHA.Google.gbsCallBack");
        scriptElement.setAttribute("type", "text/javascript");
        document.documentElement.firstChild.appendChild(scriptElement);

    },

    /**
     * Add cover pages and links to Google detail in <div
     */
    gbsCallBack: function(booksInfo) {
        for (id in booksInfo) {
            var book = booksInfo[id];
            $("."+book.bib_key).each(function() {
                var a = document.createElement("a");
                a.href = book.info_url;
				if (typeof(book.thumbnail_url) != "undefined") {
	            	var img = document.createElement("img");
	                img.src = book.thumbnail_url;
					$(this).append(img);
                    $(this).append(
                        '<div style="margin-bottom:5px; margin-top:-5px;font-size:9px">' +
                        '<a href="' + 
                        book.info_url + 
                        '"><img src="' +
                        'http://books.google.com/intl/en/googlebooks/images/gbs_preview_sticker1.gif' +
                        '"></a></div>' 
                        );
				} else {
					var message = document.createElement("span");
					$(message).attr("class","no-image");
					$(message).html(NO_GOOGLE_JACKET);
					$(this).append(message);
				}
            });
        }
    }
};
