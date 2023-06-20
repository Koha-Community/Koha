/* global __ */

if ( KOHA === undefined ) var KOHA = {};

KOHA.browser = function (searchid, biblionumber) {
    var me = this;

    if (!searchid) {
        // We are generating a clean numeric datetime representation so we can easily compare them using the default javascript lexigraphic sorter.
        searchid = 'scs_' + (new Date()).getTime(); // scs for Staff Client Search
    }
    me.searchid = searchid;

    var searches_stored = localStorage.getItem('searches');
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
            window.location = '/cgi-bin/koha/catalogue/search.pl?' + current_search.query + '&limit=' + current_search.limit + '&sort_by=' + current_search.sort + '&gotoPage=detail.pl&gotoNumber=first&searchid=' + me.searchid + '&offset=' + newSearchPos;
        } else if (newSearchPos < 0) {
            window.location = '/cgi-bin/koha/catalogue/search.pl?' + current_search.query + '&limit=' + current_search.limit + '&sort_by=' + current_search.sort + '&gotoPage=detail.pl&gotoNumber=last&searchid=' + me.searchid + '&offset=' + (me.offset - current_search.pagelen);
        } else {
            window.location = window.location.href.replace('biblionumber=' + biblionumber, 'biblionumber=' + current_search.results[newSearchPos]);
        }
    }

    me.create = function (offset, query, limit, sort, newresults, total) {
        if (current_search) {
            if (offset === parseInt(current_search.offset) - newresults.length) {
                current_search.results = newresults.concat(current_search.results);
            } else if (searchOffset = parseInt(current_search.offset) + newresults.length) {
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
        localStorage.setItem('searches', JSON.stringify(searches));
        $(document).ready(function () {
            $('#searchresults table tr a[href*="/detail.pl"]').each(function(){
                $(this).attr('href', $(this).attr('href') + '&searchid=' + me.searchid );
            });
        });
    };

    me.show = function () {
        if (current_search) {
            me.curPos = $.inArray(biblionumber, current_search.results);
            if ( parseInt(current_search.offset ) + me.curPos <= current_search.pagelen ) { // First page
                me.offset = 0;
            } else {
                me.offset = parseInt(current_search.offset) - 1;
            }

            $(document).ready(function () {
                if (me.curPos > -1) {
                    var searchURL = '/cgi-bin/koha/catalogue/search.pl?' + current_search.query + '&limit=' + current_search.limit + '&sort_by=' + current_search.sort + '&searchid=' + me.searchid + '&offset=' + me.offset;
                    var prevbutton;
                    var nextbutton;
                    if (me.curPos === 0 && parseInt(current_search.offset) === 1) {
                        prevbutton = '<span id="browse-previous" class="browse-button" title="' + __("Previous") + '"><i class="fa fa-arrow-left"></i></span>';
                    } else {
                        prevbutton = '<a href="#" id="browse-previous" class="browse-button" title="' + __("Previous") + '"><i class="fa fa-arrow-left"></i></a>';
                    }
                    if (parseInt(current_search.offset) + me.curPos == current_search.total) {
                        nextbutton = '<span id="browse-next" class="browse-button" title="' + __("Next") + '"><i class="fa fa-arrow-right"></i></span>';
                    } else {
                        nextbutton = '<a href="#" id="browse-next" class="browse-button" title="' + __("Next") + '"><i class="fa fa-arrow-right"></i></a>';
                    }
                    $('#menu').before('<div class="browse-controls"><div class="browse-controls-inner"><div class="browse-label"><a href="' + searchURL + '" id="browse-return-to-results" class="searchwithcontext"><i class="fa fa-list"></i> ' + __("Results") + '</a></div><div class="browse-prev-next">' + prevbutton + nextbutton + '</div></div></div>');
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
                        var url = new URL($(this).attr('href'), window.location.origin);
                        url.searchParams.set('searchid', me.searchid);
                        window.location = url.href;
                    });
                    $('form[name="f"]').append('<input type="hidden" name="searchid" value="' + me.searchid + '"></input>');
                }
            });
        }
    };

    me.show_back_link = function () {
        if (current_search) {
            $(document).ready(function () {
                var searchURL = '/cgi-bin/koha/catalogue/search.pl?' + current_search.query + '&limit=' + current_search.limit + '&sort_by=' + current_search.sort + '&searchid=' + me.searchid;
                $('#previous_search_link').replaceWith('<div><div class="browse-label"><a href="' + searchURL + '"><i class="fa fa-list"></i> ' + __("Go back to the results") + '</a></div></div>');
            });
        }
    };


    return me;
};
