/* global __ */
if (typeof KOHA == "undefined" || !KOHA) {
    var KOHA = {};
}

/**
 * A namespace for OpenLibrary related functions.
 */
KOHA.OpenLibrary = new (function () {
    /**
     * Search all:
     *    <div title="biblionumber" id="isbn" class="openlibrary-thumbnail"></div>
     * or
     *    <div title="biblionumber" id="isbn" class="openlibrary-thumbnail-preview"></div>
     * and run a search with all collected isbns to Open Library Book Search.
     * The result is asynchronously returned by OpenLibrary and caught by
     * olCallBack().
     */
    this.GetCoverFromIsbn = function () {
        var bibkeys = [];
        $("[id^=openlibrary-thumbnail]").each(function () {
            bibkeys.push("ISBN:" + $(this).attr("class")); // id=isbn
        });
        bibkeys = bibkeys.join(",");
        var scriptElement = document.createElement("script");
        scriptElement.setAttribute("id", "jsonScript");
        scriptElement.setAttribute(
            "src",
            "https://openlibrary.org/api/books?bibkeys=" +
                escape(bibkeys) +
                "&callback=KOHA.OpenLibrary.olCallBack&jscmd=data"
        );
        scriptElement.setAttribute("type", "text/javascript");
        document.documentElement.firstChild.appendChild(scriptElement);
    };

    /**
     * Add cover pages <div
     * and link to preview if div id is gbs-thumbnail-preview
     */
    this.olCallBack = function (booksInfo) {
        for (var id in booksInfo) {
            var book = booksInfo[id];
            var isbn = id.substring(5);
            var a;
            $("[id^=openlibrary-thumbnail]." + isbn).each(function () {
                a = document.createElement("a");
                a.href = booksInfo.url;
                if (book.cover) {
                    var img;
                    if ($(this).data("use-data-link")) {
                        a = document.createElement("a");
                        a.href = book.cover.large;
                        img = document.createElement("img");
                        img.src = book.cover.medium;
                        img.setAttribute("data-link", book.cover.large);
                        a.append(img);
                        $(this).empty().append(a);
                    } else {
                        img = document.createElement("img");
                        img.src = book.cover.medium;
                        img.height = "110";
                        $(this).append(img);
                    }
                } else {
                    var message = document.createElement("span");
                    $(message).attr("class", "no-image");
                    $(message).html(__("No cover image available"));
                    $(this).append(message);
                }
            });
        }
        this.done = 1;
    };

    var search_url = "https://openlibrary.org/search?";
    this.searchUrl = function (q) {
        var params = { q: q };
        return search_url + $.param(params);
    };

    var search_url_json = "https://openlibrary.org/search.json";
    this.search = function (q, page_no, callback) {
        var params = { q: q };
        if (page_no) {
            params.page = page_no;
        }
        $.ajax({
            type: "GET",
            url: search_url_json,
            dataType: "json",
            data: params,
            error: function (xhr) {
                try {
                    callback(JSON.parse(xhr.responseText));
                } catch (e) {
                    callback({ error: xhr.responseText || true });
                }
            },
            success: callback,
        });
    };
})();
/* readapi_automator.js */

/*
This script helps to put readable links to Open Library books into
online book catalogs.
When loaded, it searches the DOM for <div> elements with class
"ol_readapi_book", extracts book identifiers from them (e.g. isbn,
lccn, etc.) and puts those into an asynchronous call to the Read API.
When the call returns, the results are used to add clickable links
to the "ol_readapi_book" elements found earlier.
A demonstration use of this script is available here:
http://internetarchive.github.com/read_api_extras/readapi_demo.html
*/

(function () {
    // open anonymous scope for tidiness

    // 'constants'
    var readapi_bibids = ["isbn", "lccn", "oclc", "olid", "iaid", "bibkeys"];
    var magic_classname = "ol_readapi_book";
    var ol_readapi_books = $("." + magic_classname);
    var result;

    // added to book divs to correlate with API results
    var magic_bookid = "ol_bookid";
    var ol_button_classname = "ol_readapi_button";

    // Find all book divs and concatenate ids from them to create a read
    // API query url
    function create_query() {
        var q = "https://openlibrary.org/api/volumes/brief/json/";

        function add_el(i, el) {
            // tag with number found so it's easy to discover later
            // (necessary?  just go by index?)
            // (choose better name?)
            $(el).attr(magic_bookid, i);

            if (i > 0) {
                q += "|";
            }
            q += "id:" + i;

            for (var bi in readapi_bibids) {
                var bibid = readapi_bibids[bi];
                if ($(el).attr(bibid)) {
                    q += ";" + bibid + ":" + $(el).attr(bibid);
                }
            }
        }

        $("." + magic_classname).each(add_el);
        return q;
    }

    function make_read_button(bookdata) {
        var buttons = {
            "full access":
                "https://openlibrary.org/images/button-read-open-library.png",
            lendable:
                "https://openlibrary.org/images/button-borrow-open-library.png",
            "checked out":
                "https://openlibrary.org/images/button-checked-out-open-library.png",
        };
        if (bookdata.items.length == 0) {
            return false;
        }
        var first = bookdata.items[0];
        if (!(first.status in buttons)) {
            return false;
        }
        result =
            '<a target="_blank" href="' +
            first.itemURL +
            '">' +
            '<img class="' +
            ol_button_classname +
            '" src="' +
            buttons[first.status] +
            '"/></a>';
        return result;
    }

    // Default function for decorating document elements with read API data
    function default_decorate_el_fn(el, bookdata) {
        // Note that 'bookdata' may be undefined, if the Read API call
        // didn't return results for this book
        var decoration;
        if (bookdata) {
            decoration = make_read_button(bookdata);
        }
        if (decoration) {
            el.innerHTML += decoration;
            el.style.display = "block";
        } else {
            el.style.display = "none";
        }
    }

    function do_query(q, decorate_el_fn) {
        if (!decorate_el_fn) {
            decorate_el_fn = default_decorate_el_fn;
        }
        // Call a function on each <div class="ol_readapi_book"> element
        // with the target element and the data found for that element.
        // Use decorate_el_fn if supplied, falling back to
        // default_decorate_el_fn, above.
        function query_callback(data) {
            $("." + magic_classname).each(function (i, el) {
                var bookid = $(el).attr(magic_bookid);
                if (bookid && bookid in data) {
                    decorate_el_fn(el, data[bookid]);
                } else {
                    decorate_el_fn(el);
                }
            });
        }

        // console.log('calling ' + q);
        $.ajax({
            url: q,
            data: { show_all_items: "true" },
            dataType: "jsonp",
            success: query_callback,
        });
    }

    if (ol_readapi_books.length > 0) {
        // Do stuff
        var q = create_query();
        do_query(q);

        result = {
            do_query: do_query,
            create_query: create_query,
            make_read_button: make_read_button,
        };
    }

    return result;
})(); // close anonymous scope

/*
Possible futures:
* Support alternate query targets, e.g. Hathi
* show_all_items
* show_inlibrary
* ezproxy prefix (implies show_inlibrary?)
* console debug output? (check all console.log)
*/
