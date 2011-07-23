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
        $("div [id^=openlibrary-thumbnail]").each(function(i) {
            bibkeys.push("ISBN:" + $(this).attr("class")); // id=isbn
        });
        bibkeys = bibkeys.join(',');
        var scriptElement = document.createElement("script");
        scriptElement.setAttribute("id", "jsonScript");
        scriptElement.setAttribute("src",
            "http://openlibrary.org/api/books?bibkeys=" + escape(bibkeys) +
            "&callback=KOHA.OpenLibrary.olCallBack");
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
          var isbn = book.bib_key.substring(5);
          
          $("."+isbn).each(function() {
              var a = document.createElement("a");
              a.href = book.info_url;
				      if (typeof(book.thumbnail_url) != "undefined") {
	               	var img = document.createElement("img");
	                img.src = book.thumbnail_url;
					        $(this).append(img);
                  var re = /^openlibrary-thumbnail-preview/;
                  if ( re.exec($(this).attr("id")) ) {
                      $(this).append(
                        '<div style="margin-bottom:5px; margin-top:-5px;font-size:9px">' +
                        '<a href="' + 
                        book.info_url + 
                        '">Preview</a></div>' 
                      );
                  }
		     		} else {
				    	var message = document.createElement("span");
					    $(message).attr("class","no-image");
					    $(message).html(NO_OL_JACKET);
					    $(this).append(message);
				    }
        });
      }
    }
};
