if ( KOHA === undefined ) var KOHA = {};

KOHA.browser = function (searchid, biblionumber) {
    var me = this;

    if (!searchid) {
        // We are generating a clean numeric datetime representation so we can easily compare them using the default javascript lexigraphic sorter.
        searchid = 'scs_' + (new Date()).getTime(); // scs for Staff Client Search
    }
    this.searchid = searchid;

    var cookie = $.cookie(me.searchid)
    if (cookie) {
        me.searchCookie = JSON.parse(cookie);
    }

    var browseRecords = function (movement) {
        var newSearchPos = me.curPos + movement;
        if (newSearchPos > me.searchCookie.results.length - 1) {
            window.location = '/cgi-bin/koha/catalogue/search.pl?' + decodeURIComponent(me.searchCookie.query) + '&limit=' + decodeURIComponent(me.searchCookie.limit) + '&sort=' + me.searchCookie.sort + '&gotoPage=detail.pl&gotoNumber=first&searchid=' + me.searchid + '&offset=' + newSearchPos;
        } else if (newSearchPos < 0) {
            window.location = '/cgi-bin/koha/catalogue/search.pl?' + decodeURIComponent(me.searchCookie.query) + '&limit=' + decodeURIComponent(me.searchCookie.limit) + '&sort=' + me.searchCookie.sort + '&gotoPage=detail.pl&gotoNumber=last&searchid=' + me.searchid + '&offset=' + (me.offset - me.searchCookie.pagelen);
        } else {
            window.location = window.location.href.replace('biblionumber=' + biblionumber, 'biblionumber=' + me.searchCookie.results[newSearchPos]);
        }
    }

    this.create = function (offset, query, limit, sort, newresults, total) {
        if (me.searchCookie) {
            if (offset === me.searchCookie.offset - newresults.length) {
                me.searchCookie.results = newresults.concat(me.searchCookie.results);
            } else if (searchOffset = me.searchCookie.offset + newresults.length) {
                me.searchCookie.results = me.searchCookie.results.concat(newresults);
            } else {
                delete me.searchCookie;
            }
        }
        if (!me.searchCookie) {
            me.searchCookie = { offset: offset,
                query: query,
                limit: limit,
                sort:  sort,
                pagelen: newresults.length,
                results: newresults,
                total: total
            };

            //Bug_11369 Cleaning up excess searchCookies to prevent cookie overflow in the browser memory.
            var allVisibleCookieKeys = Object.keys( $.cookie() );
            var scsCookieKeys = $.grep( allVisibleCookieKeys,
                function(elementOfArray, indexInArray) {
                    return ( elementOfArray.search(/^scs_\d/) != -1 ); //We are looking for specifically staff client searchCookies.
                }
            );
            if (scsCookieKeys.length >= 10) {
                scsCookieKeys.sort(); //Make sure they are in order, oldest first!
                $.removeCookie( scsCookieKeys[0], { path: '/' } );
            }
            //EO Bug_11369
        }
        $.cookie(me.searchid, JSON.stringify(me.searchCookie), { path: '/' });
        $(document).ready(function () {
            $('#searchresults table tr a[href*="detail.pl"]').click(function (ev) {
                ev.preventDefault();
                window.location = $(this).attr('href') + '&searchid=' + me.searchid;
            });
        });
    };

    this.show = function () {
        if (me.searchCookie) {
            me.curPos = $.inArray(biblionumber, me.searchCookie.results);
            me.offset = Math.floor((me.searchCookie.offset + me.curPos - 1) / me.searchCookie.pagelen) * me.searchCookie.pagelen;

            $(document).ready(function () {
                if (me.curPos > -1) {
                    var searchURL = '/cgi-bin/koha/catalogue/search.pl?' + decodeURIComponent(me.searchCookie.query) + '&limit=' + decodeURIComponent(me.searchCookie.limit) + '&sort=' + me.searchCookie.sort + '&searchid=' + me.searchid + '&offset=' + me.offset;
                    var prevbutton;
                    var nextbutton;
                    if (me.curPos === 0 && me.searchCookie.offset === 1) {
                        prevbutton = '<span id="browse-previous" class="browse-button">« ' + BROWSER_PREVIOUS + '</span>';
                    } else {
                        prevbutton = '<a href="#" id="browse-previous" class="browse-button">« ' + BROWSER_PREVIOUS + '</a>';
                    }
                    if (me.searchCookie.offset + me.curPos == me.searchCookie.total) {
                        nextbutton = '<span id="browse-next" class="browse-button">' + BROWSER_NEXT + ' »</span>';
                    } else {
                        nextbutton = '<a href="#" id="browse-next" class="browse-button">' + BROWSER_NEXT + ' »</a>';
                    }
                    $('#menu').before('<div class="browse-controls"><div class="browse-controls-inner"><div class="browse-label"><a href="' + searchURL + '" id="browse-return-to-results" class="browse-button">' + BROWSER_RETURN_TO_SEARCH + '</a></div><div class="browse-prev-next">' + prevbutton + nextbutton + '</div></div></div>');
                    $('a#browse-previous').click(function (ev) {
                        ev.preventDefault();
                        browseRecords(-1);
                    });
                    $('a#browse-next').click(function (ev) {
                        ev.preventDefault();
                        browseRecords(1);
                    });
                    $('a[href*="biblionumber="]').click(function (ev) {
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
