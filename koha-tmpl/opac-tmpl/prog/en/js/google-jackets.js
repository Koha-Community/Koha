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
        $(".gbs-thumbnail").each(function(i) {
            bibkeys.push(this.id); // id=isbn
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
            $("#"+book.bib_key).each(function() {
                var a = document.createElement("a");
                a.href = book.info_url;
	            var img = document.createElement("img");
				if(typeof(book.thumbnail_url) != "undefined"){
	                img.src = book.thumbnail_url;
		            a.appendChild(img);
	                $(this).append(a);
				}
            });
        }
    }
};
