if (typeof KOHA == "undefined" || !KOHA) {
    var KOHA = {};
}

/**
 * A namespace for OpenLibrary related functions.
 */
KOHA.OpenLibrary = new function() {

    /**
     * Search all:
     *    <div title="biblionumber" id="isbn" class="openlibrary-thumbnail"></div>
     * or
     *    <div title="biblionumber" id="isbn" class="openlibrary-thumbnail-preview"></div>
     * and run a search with all collected isbns to Open Library Book Search.
     * The result is asynchronously returned by OpenLibrary and catched by
     * olCallBack().
     */
    this.GetCoverFromIsbn = function() {
        var bibkeys = [];
        $("[id^=openlibrary-thumbnail]").each(function(i) {
            bibkeys.push("ISBN:" + $(this).attr("class")); // id=isbn
        });
        bibkeys = bibkeys.join(',');
        var scriptElement = document.createElement("script");
        scriptElement.setAttribute("id", "jsonScript");
        scriptElement.setAttribute("src",
            "https://openlibrary.org/api/books?bibkeys=" + escape(bibkeys) +
            "&callback=KOHA.OpenLibrary.olCallBack&jscmd=data");
        scriptElement.setAttribute("type", "text/javascript");
        document.documentElement.firstChild.appendChild(scriptElement);
    }

    /**
     * Add cover pages <div
     * and link to preview if div id is gbs-thumbnail-preview
     */
    this.olCallBack = function(booksInfo) {
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
                        $(this).empty().append(img);
                        $(this).append('<div class="results_summary">' + '<a href="' + book.url + '">' + OL_PREVIEW + '</a></div>');
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

    var search_url = 'https://openlibrary.org/search?';
    this.searchUrl = function( q ) {
        var params = {q: q};
        return search_url + $.param(params);
    };

    var search_url_json = 'https://openlibrary.org/search.json';
    this.search = function( q, page_no, callback ) {
        var params = {q: q};
        if (page_no) {
            params.page = page_no;
        }
        $.ajax( {
            type: 'GET',
            url: search_url_json,
            dataType: 'json',
            data: params,
            error: function( xhr, error ) {
                try {
                    callback( JSON.parse( xhr.responseText ));
                } catch ( e ) {
                    callback( {error: xhr.responseText || true} );
                }
            },
            success: callback
        } );
    };
};
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

var ol_readapi_automator =
(function () { // open anonymous scope for tidiness

// 'constants'
var readapi_bibids = ['isbn', 'lccn', 'oclc', 'olid', 'iaid', 'bibkeys'];
var magic_classname = 'ol_readapi_book';

// added to book divs to correlate with API results
var magic_bookid = 'ol_bookid';
var ol_button_classname = 'ol_readapi_button';

// Find all book divs and concatenate ids from them to create a read
// API query url
function create_query() {
    var q = 'http://openlibrary.org/api/volumes/brief/json/';

    function add_el(i, el) {
        // tag with number found so it's easy to discover later
        // (necessary?  just go by index?)
        // (choose better name?)
        $(el).attr(magic_bookid, i);

        if (i > 0) {
            q += '|';
        }
        q += 'id:' + i;

        for (bi in readapi_bibids) {
            bibid = readapi_bibids[bi];
            if ($(el).attr(bibid)) {
                q += ';' + bibid + ':' + $(el).attr(bibid);
            }
        }
    }

    $('.' + magic_classname).each(add_el);
    return q;
}

function make_read_button(bookdata) {
    buttons = {
        'full access':
        "http://openlibrary.org/images/button-read-open-library.png",
        'lendable':
        "http://openlibrary.org/images/button-borrow-open-library.png",
        'checked out':
        "http://openlibrary.org/images/button-checked-out-open-library.png"
    };
    if (bookdata.items.length == 0) {
        return false;
    }
    first = bookdata.items[0];
    if (!(first.status in buttons)) {
        return false;
    }
    result = '<a href="' + first.itemURL + '">' +
      '<img class="' + ol_button_classname +
      '" src="' + buttons[first.status] + '"/></a>';
    return result;
}

// Default function for decorating document elements with read API data
function default_decorate_el_fn(el, bookdata) {
    // Note that 'bookdata' may be undefined, if the Read API call
    // didn't return results for this book
    if (!bookdata) {
        decoration = 'Not found';
    } else {
        decoration = make_read_button(bookdata);
    }
    if (decoration) {
        el.innerHTML += decoration;
    }
}

function do_query(q, decorate_el_fn) {
    if (!decorate_el_fn) {
        decorate_el_fn = default_decorate_el_fn;
    }
    var starttime = (new Date()).getTime();

    // Call a function on each <div class="ol_readapi_book"> element
    // with the target element and the data found for that element.
    // Use decorate_el_fn if supplied, falling back to
    // default_decorate_el_fn, above.
    function query_callback(data, textStatus, jqXHR) {
        var endtime = (new Date()).getTime();
        var duration = (endtime - starttime) / 1000;
        // console.log('took ' + duration + ' seconds');

        $('.' + magic_classname).each(function(i, el) {
                var bookid = $(el).attr(magic_bookid);
                if (bookid && bookid in data) {
                    decorate_el_fn(el, data[bookid]);
                } else {
                    decorate_el_fn(el);
                }
            });
    }

    // console.log('calling ' + q);
    $.ajax({ url: q,
                data: { 'show_all_items': 'true' },
                dataType: 'jsonp',
                success: query_callback
                });
}

// Do stuff
var q = create_query();
do_query(q);

result = {
    do_query: do_query,
    create_query: create_query,
    make_read_button: make_read_button
};

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
