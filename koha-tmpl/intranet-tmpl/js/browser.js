if ( KOHA === undefined ) var KOHA = {};

KOHA.browser = function (searchid, biblionumber) {
    var me = this;

    if (!searchid) {
        // We are generating a clean numeric datetime representation so we can easily compare them using the default javascript lexigraphic sorter.
        searchid = 'scs_' + (new Date()).getTime(); // scs for Staff Client Search
    }
    me.searchid = searchid;

    var searches_stored = sessionStorage.getItem('searches');
    var current_search;
    var searches = {};
    if ( searches_stored ) {
        searches = JSON.parse(searches_stored);
        current_search = searches[me.searchid];

        // Remove old entries
        var searchids = Object.keys(searches);
        var nb_searches = searchids.length;
        if ( nb_searches > 20 ) { // No need to keep more than 20 searches
            searchids = searchids.sort();
            for ( var i = 0 ; i < nb_searches - 20 ; i++ ) {
                delete searches[searchids[i]];
            }
        }
    }

    var browseRecords = function (movement) {
        var newSearchPos = me.curPos + movement;
        if (newSearchPos > current_search.results.length - 1) {
            window.location = '/cgi-bin/koha/catalogue/search.pl?' + decodeURIComponent(current_search.query) + '&limit=' + decodeURIComponent(current_search.limit) + '&sort=' + current_search.sort + '&gotoPage=detail.pl&gotoNumber=first&searchid=' + me.searchid + '&offset=' + newSearchPos;
        } else if (newSearchPos < 0) {
            window.location = '/cgi-bin/koha/catalogue/search.pl?' + decodeURIComponent(current_search.query) + '&limit=' + decodeURIComponent(current_search.limit) + '&sort=' + current_search.sort + '&gotoPage=detail.pl&gotoNumber=last&searchid=' + me.searchid + '&offset=' + (me.offset - current_search.pagelen);
        } else {
            window.location = window.location.href.replace('biblionumber=' + biblionumber, 'biblionumber=' + current_search.results[newSearchPos]);
        }
    }

    me.create = function (offset, query, limit, sort, newresults, total) {
        if (current_search) {
            if (offset === current_search.offset - newresults.length) {
                current_search.results = newresults.concat(current_search.results);
            } else if (searchOffset = current_search.offset + newresults.length) {
                current_search.results = current_search.results.concat(newresults);
            } else {
                delete current_search;
            }
        }
        if (!current_search) {
            current_search = { offset: offset,
                query: query,
                limit: limit,
                sort:  sort,
                pagelen: newresults.length,
                results: newresults,
                total: total,
                searchid: searchid
            };
        }
        searches[me.searchid] = current_search;
        sessionStorage.setItem('searches', JSON.stringify(searches));
        $(document).ready(function () {
            //FIXME It's not a good idea to modify the click events
            $('#searchresults table tr a[href*="detail.pl"]').on('click', function (ev) {
                ev.preventDefault();
            });
            $('#searchresults table tr a[href*="detail.pl"]').on('mousedown', function (ev) {
                if ( ev.which == 2 || ev.which == 1 && ev.ctrlKey ) {
                    // Middle click or ctrl + click
                    ev.preventDefault();
                    var newwindow = window.open( $(this).attr('href') + '&searchid=' + me.searchid, '_blank' )
                    newwindow.blur();
                    window.focus();
                } else if ( ev.which == 1 ) {
                    // Left click
                    ev.preventDefault();
                    window.location = $(this).attr('href') + '&searchid=' + me.searchid;
                }
            });
        });
    };

    me.show = function () {
        if (current_search) {
            me.curPos = $.inArray(biblionumber, current_search.results);
            me.offset = Math.floor((current_search.offset + me.curPos - 1) / current_search.pagelen) * current_search.pagelen;

            $(document).ready(function () {
                if (me.curPos > -1) {
                    var searchURL = '/cgi-bin/koha/catalogue/search.pl?' + decodeURIComponent(current_search.query) + '&limit=' + decodeURIComponent(current_search.limit) + '&sort=' + current_search.sort + '&searchid=' + me.searchid + '&offset=' + me.offset;
                    var prevbutton;
                    var nextbutton;
                    if (me.curPos === 0 && current_search.offset === 1) {
                        prevbutton = '<span id="browse-previous" class="browse-button">« ' + BROWSER_PREVIOUS + '</span>';
                    } else {
                        prevbutton = '<a href="#" id="browse-previous" class="browse-button">« ' + BROWSER_PREVIOUS + '</a>';
                    }
                    if (current_search.offset + me.curPos == current_search.total) {
                        nextbutton = '<span id="browse-next" class="browse-button">' + BROWSER_NEXT + ' »</span>';
                    } else {
                        nextbutton = '<a href="#" id="browse-next" class="browse-button">' + BROWSER_NEXT + ' »</a>';
                    }
                    $('#menu').before('<div class="browse-controls"><div class="browse-controls-inner"><div class="browse-label"><a href="' + searchURL + '" id="browse-return-to-results" class="browse-button searchwithcontext">' + BROWSER_RETURN_TO_SEARCH + '</a></div><div class="browse-prev-next">' + prevbutton + nextbutton + '</div></div></div>');
                    $('a#browse-previous').click(function (ev) {
                        ev.preventDefault();
                        browseRecords(-1);
                    });
                    $('a#browse-next').click(function (ev) {
                        ev.preventDefault();
                        browseRecords(1);
                    });
                    $('a[href*="biblionumber="]').not('a[target="_blank"]').click(function (ev) {
                        ev.preventDefault();
                        window.location = $(this).attr('href') + '&searchid=' + me.searchid;
                    });
                    $('form[name="f"]').append('<input type="hidden" name="searchid" value="' + me.searchid + '"></input>');
                }
            });
        }
    };

    return me;
};
